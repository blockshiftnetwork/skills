#!/usr/bin/env bash
#
# sail-wt.sh — create, run and retire git worktrees of a Laravel Sail project in isolation.
#
#   sail-wt.sh <folder> <branch>        create ../<folder>, boot it, migrate --seed
#              [--from <ref>] [--keep]  base a new branch on <ref>; leave other stacks running
#   sail-wt.sh ls                       list worktrees, their URL, state and resource use
#   sail-wt.sh start <folder>           start a worktree's stack (stops the others)
#   sail-wt.sh stop  <folder>|--all     stop one stack, or every worktree stack
#   sail-wt.sh rm    <folder> [--yes]   destroy the stack and volumes, remove the worktree
#
# Run from anywhere inside the main repository or one of its worktrees.
#
# Resource control. Every Sail stack is a PHP app container plus a database, Redis and
# whatever else compose.yaml declares, so three stacks running at once means three of
# each. This script keeps that in check in two ways:
#   1. Exclusive mode (default): creating or starting a worktree stops every other
#      worktree's stack first. Containers are stopped, not removed, so data survives and
#      `start` brings a stack back in seconds. Pass --keep to leave the others running.
#   2. Per-worktree limits: each new worktree gets a git-ignored compose.override.yaml
#      capping CPU and memory per service, and fewer PHP server workers.
#
# Environment overrides:
#   SAIL_WT_ENV_FROM      .env to copy values from (default: the main checkout's .env);
#                         "example" starts from .env.example alone
#   SAIL_WT_PHP           PHP version for the bootstrap container (default: detected)
#   SAIL_WT_NO_SEED=1     run `migrate` without `--seed`
#   SAIL_WT_LIMITS=0      do not write compose.override.yaml
#   SAIL_WT_APP_CPUS      app container CPUs           (default 2)
#   SAIL_WT_APP_MEM       app container memory         (default 3g)
#   SAIL_WT_DB_CPUS       database CPUs                (default 1)
#   SAIL_WT_DB_MEM        database memory              (default 1g)
#   SAIL_WT_SVC_CPUS      every other service's CPUs   (default 0.5)
#   SAIL_WT_SVC_MEM       every other service's memory (default 512m)
#   SAIL_WT_PHP_WORKERS   PHP_CLI_SERVER_WORKERS       (default 2)

set -Eeuo pipefail

# ---------------------------------------------------------------- output helpers
if [[ -t 1 ]]; then
    BOLD=$'\e[1m'; DIM=$'\e[2m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; RED=$'\e[31m'; RESET=$'\e[0m'
else
    BOLD=''; DIM=''; GREEN=''; YELLOW=''; RED=''; RESET=''
fi

step() { printf '%s==>%s %s\n' "$BOLD" "$RESET" "$*"; }
warn() { printf '%s!!%s  %s\n' "$YELLOW" "$RESET" "$*" >&2; }
die()  { printf '%sxx%s  %s\n' "$RED" "$RESET" "$*" >&2; exit 1; }

trap 'printf "%sxx%s  Failed at line %s: %s\n" "$RED" "$RESET" "$LINENO" "$BASH_COMMAND" >&2' ERR

usage() {
    cat <<EOF
Usage:
  $(basename "$0") <folder> <branch> [--from <ref>] [--keep]
                                               create ../<folder> on <branch> and boot it
  $(basename "$0") ls                           list worktrees and their stacks
  $(basename "$0") start <folder> [--keep]      start a stack (stops the others unless --keep)
  $(basename "$0") stop <folder>|--all          stop one stack or all worktree stacks
  $(basename "$0") rm <folder> [--yes]          remove stack, volumes and worktree

  <branch> may be an existing local branch, a remote branch on origin, or a new branch.
  A new branch starts from <ref> (e.g. origin/main) when --from is given, else from HEAD,
  and never tracks it, so a later push cannot land on <ref> by accident.
EOF
    exit 1
}

for bin in git docker ss; do
    command -v "$bin" >/dev/null || die "'$bin' is required but not installed."
done

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || die "Run this from inside the repository."
# From inside another worktree, still resolve the main checkout and place new worktrees beside it.
MAIN_ROOT="$(dirname "$(git -C "$REPO_ROOT" rev-parse --path-format=absolute --git-common-dir)")"
PARENT_DIR="$(dirname "$MAIN_ROOT")"

# ---------------------------------------------------------------- shared helpers
worktree_paths() {
    git -C "$MAIN_ROOT" worktree list --porcelain | sed -n 's/^worktree //p'
}

# Read KEY from a .env file (default: ./.env).
env_value() {
    local file="${2:-.env}"
    [[ -f "$file" ]] || return 0
    { grep -E "^${1}=" "$file" || true; } | tail -n1 | cut -d= -f2- | sed -E 's/^"(.*)"$/\1/'
}

# Compose project of a worktree: COMPOSE_PROJECT_NAME, else compose's default (the dir name).
project_of() {
    local name
    name="$(env_value COMPOSE_PROJECT_NAME "$1/.env")"
    [[ -n "$name" ]] || name="$(printf "%s" "$(basename "$1")" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_-')"
    printf '%s' "$name"
}

running_count() {
    docker ps -q --filter "label=com.docker.compose.project=$1" | wc -l | tr -d ' '
}

resolve_worktree() {
    local path="$PARENT_DIR/$1"
    worktree_paths | grep -qxF "$path" || die "$path is not a worktree of $MAIN_ROOT."
    printf '%s' "$path"
}

stop_stack() {
    local path="$1" project
    project="$(project_of "$path")"
    [[ "$(running_count "$project")" -gt 0 ]] || return 0
    step "Stopping $project"
    if [[ -x "$path/vendor/bin/sail" ]]; then
        (cd "$path" && ./vendor/bin/sail stop >/dev/null)
    else
        docker stop $(docker ps -q --filter "label=com.docker.compose.project=$project") >/dev/null
    fi
}

stop_others() {
    local keep_path="$1" path
    while IFS= read -r path; do
        [[ "$path" == "$keep_path" ]] || stop_stack "$path"
    done < <(worktree_paths)
}

# ---------------------------------------------------------------- ls
cmd_ls() {
    local path project count state url stats
    printf '%s%-28s %-34s %-10s %-24s %s%s\n' "$BOLD" "PATH" "BRANCH" "STATE" "URL" "CPU / MEM" "$RESET"
    while IFS= read -r path; do
        project="$(project_of "$path")"
        count="$(running_count "$project")"
        state="stopped"; stats="-"
        if [[ "$count" -gt 0 ]]; then
            state="running"
            stats="$(docker stats --no-stream --format '{{.CPUPerc}} {{.MemUsage}}' \
                $(docker ps -q --filter "label=com.docker.compose.project=$project") \
                | awk '{gsub("%","",$1); cpu+=$1; m=$2; v=m+0; if (m ~ /GiB/) v*=1024; else if (m ~ /KiB/) v/=1024; mem+=v}
                       END {printf "%.0f%% / %.0fMiB", cpu, mem}')"
        fi
        url="http://localhost:$(env_value APP_PORT "$path/.env")"
        [[ "$url" == "http://localhost:" ]] && url="http://localhost"
        printf '%-28s %-34s %-10s %-24s %s\n' \
            "${path#"$PARENT_DIR"/}" "$(git -C "$path" branch --show-current 2>/dev/null || echo '?')" "$state" "$url" "$stats"
    done < <(worktree_paths)
}

# ---------------------------------------------------------------- start / stop / rm
cmd_start() {
    local folder="${1:-}" keep="${2:-}" path
    [[ -n "$folder" ]] || usage
    path="$(resolve_worktree "$folder")"
    [[ "$keep" == "--keep" ]] || stop_others "$path"
    step "Starting $(project_of "$path")"
    (cd "$path" && ./vendor/bin/sail up -d)
    printf '\n  %s%shttp://localhost:%s%s\n' "$GREEN" "$BOLD" "$(env_value APP_PORT "$path/.env")" "$RESET"
}

cmd_stop() {
    local target="${1:-}" path
    [[ -n "$target" ]] || usage
    if [[ "$target" == "--all" ]]; then
        while IFS= read -r path; do stop_stack "$path"; done < <(worktree_paths)
    else
        stop_stack "$(resolve_worktree "$target")"
    fi
}

cmd_rm() {
    local folder="${1:-}" confirmed="${2:-}" path answer
    [[ -n "$folder" ]] || usage
    path="$(resolve_worktree "$folder")"
    [[ "$path" != "$MAIN_ROOT" ]] || die "Refusing to remove the main checkout."
    if [[ "$confirmed" != "--yes" ]]; then
        read -r -p "Delete containers, volumes (database data) and worktree $path? [y/N] " answer
        [[ "$answer" =~ ^[Yy]$ ]] || die "Aborted."
    fi
    if [[ -x "$path/vendor/bin/sail" ]]; then
        (cd "$path" && ./vendor/bin/sail down -v --remove-orphans)
    fi
    # Containers write files as the sail user; --force covers untracked vendor/, .env, etc.
    git -C "$MAIN_ROOT" worktree remove --force "$path"
    step "Removed $path (branch kept; delete it with: git branch -D <branch>)"
}

# ---------------------------------------------------------------- create
# Set KEY=VALUE in ./.env, replacing the first (possibly commented) occurrence and dropping
# repeats, or appending. Pure bash so secrets containing |, &, \ or / are written verbatim.
set_env() {
    local key="$1" value="$2" line found=0 tmp
    tmp="$(mktemp .env.XXXXXX)"
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^#?[[:space:]]*${key}= ]]; then
            (( found )) || printf '%s=%s\n' "$key" "$value"
            found=1
        else
            printf '%s\n' "$line"
        fi
    done < .env > "$tmp"
    (( found )) || printf '%s=%s\n' "$key" "$value" >> "$tmp"
    mv "$tmp" .env
}

# Copy every active KEY=VALUE from $1 onto ./.env. Keys the branch's .env.example added keep
# their example value; keys only the source has are appended. Returns the count via OVERLAID.
overlay_env() {
    local source="$1" line key value
    OVERLAID=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]] || continue
        key="${BASH_REMATCH[1]}"; value="${BASH_REMATCH[2]}"
        if [[ "$value" == '"' || ( "$value" == '"'* && "$value" != *'"' ) ]]; then
            warn "$key looks like a multi-line value; copy it into the worktree's .env by hand."
            continue
        fi
        set_env "$key" "$value"
        OVERLAID=$((OVERLAID + 1))
    done < "$source"
}

detect_php_version() {
    if [[ -n "${SAIL_WT_PHP:-}" ]]; then
        printf '%s' "$SAIL_WT_PHP"; return
    fi
    # Prefer the runtime the compose file builds, then the composer.json PHP constraint.
    local v
    v="$(grep -oE '(sail/runtimes|docker)/[0-9]+\.[0-9]+' "${COMPOSE_FILE_PATH:-/dev/null}" 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' || true)"
    [[ -z "$v" ]] && v="$(grep -oE '"php"[[:space:]]*:[[:space:]]*"[^0-9]*[0-9]+\.[0-9]+' composer.json | grep -oE '[0-9]+\.[0-9]+' | tail -n1 || true)"
    printf '%s' "${v:-8.4}"
}

# Cap CPU and memory per service. docker compose merges compose.override.yaml automatically.
write_resource_limits() {
    local services service cpus mem
    services="$(docker compose config --services 2>/dev/null)" || { warn "Could not list compose services; skipping limits."; return; }
    if [[ -f compose.override.yaml ]]; then
        warn "compose.override.yaml is tracked in this branch; skipping resource limits."
        return
    fi
    if [[ -n "$(env_value SAIL_FILES)$(env_value COMPOSE_FILE)" ]]; then
        warn "SAIL_FILES or COMPOSE_FILE is set in .env, so compose.override.yaml is not loaded; skipping resource limits."
        return
    fi
    {
        echo "# Written by sail-wt.sh: resource caps for this worktree only. Safe to edit or delete."
        echo "services:"
        while IFS= read -r service; do
            case "$service" in
                laravel.test) cpus="${SAIL_WT_APP_CPUS:-2}"; mem="${SAIL_WT_APP_MEM:-3g}" ;;
                pgsql|mysql|mariadb) cpus="${SAIL_WT_DB_CPUS:-1}"; mem="${SAIL_WT_DB_MEM:-1g}" ;;
                *) cpus="${SAIL_WT_SVC_CPUS:-0.5}"; mem="${SAIL_WT_SVC_MEM:-512m}" ;;
            esac
            printf '    %s:\n        deploy:\n            resources:\n                limits:\n' "$service"
            printf "                    cpus: '%s'\n                    memory: %s\n" "$cpus" "$mem"
        done <<< "$services"
    } > compose.override.yaml

    # Keep it out of `git status` even if the project does not ignore it.
    local exclude
    exclude="$(git rev-parse --path-format=absolute --git-common-dir)/info/exclude"
    mkdir -p "$(dirname "$exclude")"
    grep -qxF '/compose.override.yaml' "$exclude" 2>/dev/null || echo '/compose.override.yaml' >> "$exclude"
}

cmd_create() {
    local FOLDER="$1" BRANCH="$2" KEEP="" FROM=""
    shift 2
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --keep) KEEP="--keep"; shift ;;
            --from) [[ -n "${2:-}" ]] || usage; FROM="$2"; shift 2 ;;
            *) usage ;;
        esac
    done
    [[ "$FOLDER" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || die "Folder name must start with a letter or digit and contain only letters, digits, '.', '_' and '-'."
    git check-ref-format --branch "$BRANCH" >/dev/null 2>&1 || die "'$BRANCH' is not a valid branch name."
    docker info >/dev/null 2>&1 || die "Docker daemon is not reachable."

    local WT_PATH="$PARENT_DIR/$FOLDER"
    [[ -e "$WT_PATH" ]] && die "$WT_PATH already exists."
    [[ -f "$MAIN_ROOT/.env.example" ]] || die "No .env.example in $MAIN_ROOT."

    # 1. worktree -------------------------------------------------------------
    step "Creating worktree $WT_PATH on branch $BRANCH"
    git -C "$MAIN_ROOT" fetch --quiet origin "$BRANCH" 2>/dev/null || true
    if [[ -n "$FROM" && "$FROM" == origin/* ]]; then
        git -C "$MAIN_ROOT" fetch --quiet origin "${FROM#origin/}" || die "Could not fetch $FROM."
    fi
    if git -C "$MAIN_ROOT" show-ref --verify --quiet "refs/heads/$BRANCH"; then
        [[ -z "$FROM" ]] || warn "$BRANCH already exists; ignoring --from $FROM."
        git -C "$MAIN_ROOT" worktree add "$WT_PATH" "$BRANCH"
    elif git -C "$MAIN_ROOT" show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
        [[ -z "$FROM" ]] || warn "origin/$BRANCH already exists; ignoring --from $FROM."
        git -C "$MAIN_ROOT" worktree add --track -b "$BRANCH" "$WT_PATH" "origin/$BRANCH"
    else
        if [[ -n "$FROM" ]]; then
            git -C "$MAIN_ROOT" rev-parse --verify --quiet "$FROM^{commit}" >/dev/null || die "Unknown ref '$FROM'."
            git -C "$MAIN_ROOT" worktree add --no-track -b "$BRANCH" "$WT_PATH" "$FROM"
        else
            git -C "$MAIN_ROOT" worktree add -b "$BRANCH" "$WT_PATH"
        fi
    fi
    cd "$WT_PATH"

    # 2. .env -----------------------------------------------------------------
    local ENV_FROM="${SAIL_WT_ENV_FROM:-$MAIN_ROOT/.env}"
    cp .env.example .env
    chmod 600 .env
    if [[ "$ENV_FROM" != "example" && -f "$ENV_FROM" ]]; then
        step "Writing .env from .env.example + values from $ENV_FROM"
        overlay_env "$ENV_FROM"
        printf '    %s%s keys copied%s\n' "$DIM" "$OVERLAID" "$RESET"
    else
        [[ "$ENV_FROM" == "example" ]] || warn "$ENV_FROM not found; using .env.example only."
        step "Writing .env from .env.example"
    fi
    # Everything below is per-worktree and overrides whatever was copied.
    local PROJECT_NAME
    PROJECT_NAME="$(printf '%s' "$FOLDER" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9_-' '_' | sed -E 's/^[^a-z0-9]+//')"
    [[ -n "$PROJECT_NAME" ]] || die "Could not derive a compose project name from '$FOLDER'."
    set_env COMPOSE_PROJECT_NAME "$PROJECT_NAME"
    set_env WWWUSER "$(id -u)"
    set_env WWWGROUP "$(id -g)"
    set_env PHP_CLI_SERVER_WORKERS "${SAIL_WT_PHP_WORKERS:-2}"

    # 3. ports ----------------------------------------------------------------
    step "Allocating host ports"
    # Ports promised to other worktrees count as taken even while their stacks are stopped.
    declare -gA TAKEN=()
    local wt port
    while IFS= read -r wt; do
        [[ "$wt" == "$WT_PATH" || ! -f "$wt/.env" ]] && continue
        while IFS= read -r port; do
            [[ "$port" =~ ^[0-9]+$ ]] && TAKEN["$port"]=1
        done < <(grep -E '^(APP_PORT|VITE_PORT|FORWARD_[A-Z_]+_PORT)=' "$wt/.env" | cut -d= -f2-)
    done < <(worktree_paths)

    port_is_free() {
        [[ -z "${TAKEN[$1]:-}" ]] || return 1
        [[ -z "$(ss -Htln "sport = :$1" 2>/dev/null)" ]] || return 1
        [[ -z "$(docker ps -aq --filter "publish=$1" 2>/dev/null)" ]] || return 1
    }
    # Sets NEXT_PORT instead of printing it: a $(...) subshell would lose the TAKEN entry.
    next_free_port() {
        local p="$1"
        while ! port_is_free "$p"; do
            p=$((p + 1))
            (( p < 65535 )) || die "No free port found starting from $1."
        done
        TAKEN["$p"]=1
        NEXT_PORT="$p"
    }

    declare -A PORT_BASES=([APP_PORT]=8080 [VITE_PORT]=5173 [FORWARD_DB_PORT]=5432 [FORWARD_REDIS_PORT]=6379)
    COMPOSE_FILE_PATH="$(ls compose.yaml compose.yml docker-compose.yml docker-compose.yaml 2>/dev/null | head -n1 || true)"
    if [[ -n "$COMPOSE_FILE_PATH" ]]; then
        # Pick up any other FORWARD_*_PORT the compose file publishes (RustFS, Mailpit, ...).
        local var base
        while IFS=: read -r var base; do
            [[ -n "${PORT_BASES[$var]:-}" ]] || PORT_BASES["$var"]="$base"
        done < <(grep -oE '\$\{FORWARD_[A-Z_]+_PORT:-[0-9]+\}' "$COMPOSE_FILE_PATH" | sed -E 's/\$\{([A-Z_]+):-([0-9]+)\}/\1:\2/' | sort -u)
    fi

    declare -A PORTS=()
    for var in APP_PORT VITE_PORT FORWARD_DB_PORT FORWARD_REDIS_PORT $(printf '%s\n' "${!PORT_BASES[@]}" | sort); do
        [[ -n "${PORTS[$var]:-}" ]] && continue
        next_free_port "${PORT_BASES[$var]}"
        PORTS["$var"]="$NEXT_PORT"
        set_env "$var" "${PORTS[$var]}"
        printf '    %s%-28s%s %s\n' "$DIM" "$var" "$RESET" "${PORTS[$var]}"
    done
    set_env APP_URL "http://localhost:${PORTS[APP_PORT]}"

    # 4. composer install -----------------------------------------------------
    # Prefer the app image Sail already built (sail-<php>/app): exact PHP and extensions, so no
    # --ignore-platform-reqs. Laravel's laravelsail/phpXX-composer images stopped at php84 and
    # are no longer in the docs, so the fallback is the official composer:2 image.
    local PHP_VERSION COMPOSER_IMAGE COMPOSER_CACHE PLATFORM_FLAG=""
    PHP_VERSION="$(detect_php_version)"
    COMPOSER_IMAGE="sail-${PHP_VERSION}/app"
    COMPOSER_CACHE="${COMPOSER_CACHE_DIR:-$HOME/.cache/composer}"
    mkdir -p "$COMPOSER_CACHE"

    if ! docker image inspect "$COMPOSER_IMAGE" >/dev/null 2>&1; then
        warn "$COMPOSER_IMAGE is not built yet; using composer:2 with --ignore-platform-reqs."
        COMPOSER_IMAGE="composer:2"
        PLATFORM_FLAG="--ignore-platform-reqs"
    fi
    step "Installing Composer dependencies with $COMPOSER_IMAGE"
    # The shared cache makes every worktree after the first install from disk, not the network.
    docker run --rm \
        --entrypoint '' \
        -u "$(id -u):$(id -g)" \
        -v "$WT_PATH:/var/www/html" \
        -v "$COMPOSER_CACHE:/tmp/composer-cache" \
        -e COMPOSER_CACHE_DIR=/tmp/composer-cache \
        -e COMPOSER_HOME=/tmp/composer-home \
        -w /var/www/html \
        "$COMPOSER_IMAGE" \
        composer install $PLATFORM_FLAG --no-interaction --prefer-dist
    [[ -x ./vendor/bin/sail ]] || die "vendor/bin/sail missing after composer install; is laravel/sail a dependency?"

    # 5. resource limits and exclusive mode -----------------------------------
    if [[ "${SAIL_WT_LIMITS:-1}" != "0" ]]; then
        step "Writing compose.override.yaml resource limits"
        write_resource_limits
    fi
    if [[ "$KEEP" != "--keep" ]]; then
        stop_others "$WT_PATH"
    fi

    # 6. sail up --------------------------------------------------------------
    step "Starting Sail (project: $PROJECT_NAME)"
    ./vendor/bin/sail up -d

    # 7. database -------------------------------------------------------------
    local DB_SERVICE="" CONTAINER_ID status attempt
    case "$(env_value DB_CONNECTION)" in
        pgsql|mysql|mariadb) DB_SERVICE="$(env_value DB_CONNECTION)" ;;
    esac
    if [[ -n "$DB_SERVICE" ]]; then
        step "Waiting for $DB_SERVICE to become healthy"
        CONTAINER_ID="$(./vendor/bin/sail ps -q "$DB_SERVICE" 2>/dev/null || true)"
        [[ -n "$CONTAINER_ID" ]] || die "No running '$DB_SERVICE' container in project $PROJECT_NAME."
        for attempt in $(seq 1 60); do
            status="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$CONTAINER_ID")"
            [[ "$status" == "healthy" ]] && break
            [[ "$status" == "unhealthy" || "$status" == "exited" ]] && die "$DB_SERVICE is $status. Check: ./vendor/bin/sail logs $DB_SERVICE"
            (( attempt == 60 )) && die "$DB_SERVICE was not healthy after 120s (last status: $status)."
            sleep 2
        done
    fi

    # A copied APP_KEY is kept, so values encrypted under the main checkout still decrypt.
    if [[ -z "$(env_value APP_KEY)" ]]; then
        step "Generating APP_KEY"
        ./vendor/bin/sail artisan key:generate --no-interaction --ansi
    fi

    if [[ "${SAIL_WT_NO_SEED:-0}" == "1" ]]; then
        step "Running migrations"
        ./vendor/bin/sail artisan migrate --no-interaction --force --ansi
    else
        step "Running migrations and seeders"
        ./vendor/bin/sail artisan migrate --seed --no-interaction --force --ansi
    fi

    local PM="npm" DEV_ARGS="-- --port ${PORTS[VITE_PORT]} --strictPort"
    if [[ -f pnpm-lock.yaml ]]; then PM="pnpm"
    elif [[ -f yarn.lock ]]; then PM="yarn"
    elif [[ -f bun.lock || -f bun.lockb ]]; then PM="bun"
    fi
    [[ "$PM" == "npm" ]] || DEV_ARGS="--port ${PORTS[VITE_PORT]} --strictPort"

    trap - ERR
    cat <<EOF

${GREEN}${BOLD}Worktree ready.${RESET}

  App        ${BOLD}http://localhost:${PORTS[APP_PORT]}${RESET}
  Path       $WT_PATH
  Branch     $BRANCH
  Project    $PROJECT_NAME
  DB port    ${PORTS[FORWARD_DB_PORT]}   Redis port ${PORTS[FORWARD_REDIS_PORT]}

  Front end  cd $WT_PATH && ./vendor/bin/sail $PM install && ./vendor/bin/sail $PM run dev $DEV_ARGS
  Overview   $(basename "$0") ls
  Pause      $(basename "$0") stop $FOLDER
  Tear down  $(basename "$0") rm $FOLDER
EOF
}

# ---------------------------------------------------------------- dispatch
case "${1:-}" in
    ls)          cmd_ls ;;
    start)       shift; cmd_start "$@" ;;
    stop)        shift; cmd_stop "$@" ;;
    rm)          shift; cmd_rm "$@" ;;
    ''|-h|--help) usage ;;
    *)           [[ $# -ge 2 ]] || usage; cmd_create "$@" ;;
esac
