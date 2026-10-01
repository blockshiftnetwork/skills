# laravel-sail-worktrees reference

## Requirements

- `git`, `docker` with the compose plugin, and `ss` (from iproute2).
- A Laravel project that uses Sail: a `compose.yaml` (or `docker-compose.yml`) with a `laravel.test` service, a `.env.example`, and `laravel/sail` in `composer.json`.

## Install as a command

```bash
mkdir -p ~/.local/bin
ln -s <path-to>/laravel-sail-worktrees/scripts/sail-wt.sh ~/.local/bin/sail-wt
```

`~/.local/bin` must be on `PATH`. Because the command is a symlink, editing the script updates it.

To make the skill available in every project, link the skill directory too:

```bash
ln -s <path-to>/laravel-sail-worktrees ~/.claude/skills/laravel-sail-worktrees
```

## Commands

| Command | Effect |
| --- | --- |
| `sail-wt <folder> <branch> [--from <ref>] [--keep]` | Create `../<folder>` on `<branch>`, boot it, run `migrate --seed` |
| `sail-wt ls` | Each worktree with its branch, state, URL and live CPU and memory |
| `sail-wt start <folder> [--keep]` | Start a stack |
| `sail-wt stop <folder>` / `sail-wt stop --all` | Stop one stack or all of them; containers and volumes stay |
| `sail-wt rm <folder> [--yes]` | Remove containers, volumes and the worktree; the branch is kept |

The branch is resolved in this order:

1. **A local branch:** used as is.
2. **A branch that exists only on `origin`:** checked out tracking `origin/<branch>`.
3. **A new name:** created from `--from <ref>`, or from HEAD if `--from` isn't given, without upstream tracking. `--from origin/<x>` fetches `<x>` first, and `--from` is ignored, with a warning, when the branch already exists.

## What `create` does

1. **Worktree:** runs `git worktree add` to `../<folder>`, beside the main checkout even when invoked from another worktree.
2. **`.env`:** starts from the branch's `.env.example` and copies every active `KEY=VALUE` from the main checkout's `.env` on top, verbatim. Values containing `|`, `&`, `\` or `/` are safe. Keys that exist only in the main `.env` are appended. Multi-line quoted values, such as PEM keys, are skipped with a warning. `APP_KEY` is kept, so values encrypted under the main checkout still decrypt. The file is created with mode `600`.
3. **Per-worktree keys:** `COMPOSE_PROJECT_NAME` (the folder name in lowercase, unsafe characters replaced by `_`), `WWWUSER`, `WWWGROUP` and `PHP_CLI_SERVER_WORKERS`.
4. **Ports:** `APP_PORT` (searched from 8080), `VITE_PORT` (5173), `FORWARD_DB_PORT` (5432), `FORWARD_REDIS_PORT` (6379), and every other `${FORWARD_*_PORT:-N}` in the compose file (searched from N). A port is taken if something listens on it, if any container publishes it (even a stopped one), or if another worktree's `.env` claims it. `APP_URL` follows `APP_PORT`.
5. **Composer:** runs `composer install` in a one-off container.
   - It uses the app image Sail already built (`sail-<php>/app`). The PHP version comes from the build context in the compose file (`vendor/laravel/sail/runtimes/X.Y` or a published `docker/X.Y`), then from `composer.json`. Because PHP and its extensions match exactly, platform checks stay on.
   - If that image isn't built yet, it falls back to the official `composer:2` image with `--ignore-platform-reqs`.
   - The `laravelsail/phpXX-composer` images from the Laravel 11 docs aren't used: they stop at PHP 8.4 and were dropped from later docs.
   - `~/.cache/composer` is shared between worktrees, so installs after the first come from disk.
6. **Resource limits:** writes `compose.override.yaml` (see below), then stops the other stacks unless `--keep` was passed, then runs `sail up -d`.
7. **Database:** waits for the database container's healthcheck (`pgsql`, `mysql` or `mariadb`, chosen by `DB_CONNECTION`). It runs `key:generate` only when `APP_KEY` is empty, then `migrate --seed`.

## Resource limits

Each stack is a PHP container plus a database, a cache and whatever else the compose file declares. Two mechanisms keep several stacks from using up the machine:

- **Exclusive mode:** `create` and `start` stop every other worktree's stack unless `--keep` is passed. They use `sail stop`, not `down`, so containers and data survive and `start` brings a stack back in seconds.
- **Caps:** each new worktree gets a `compose.override.yaml`, which docker compose merges automatically. It is added to `.git/info/exclude`. If the branch already tracks a `compose.override.yaml`, the caps are skipped with a warning.

| Service | CPUs | Memory | Variables |
| --- | --- | --- | --- |
| `laravel.test` | 2 | 3g | `SAIL_WT_APP_CPUS`, `SAIL_WT_APP_MEM` |
| `pgsql`, `mysql`, `mariadb` | 1 | 1g | `SAIL_WT_DB_CPUS`, `SAIL_WT_DB_MEM` |
| any other service | 0.5 | 512m | `SAIL_WT_SVC_CPUS`, `SAIL_WT_SVC_MEM` |

`PHP_CLI_SERVER_WORKERS` is set to 2; Sail's default is 8. `SAIL_WT_PHP_WORKERS` overrides it. To change the caps of an existing worktree, edit its `compose.override.yaml` and run `sail up -d`.

The app container gets 2 CPUs, so run parallel tests with at most 2 processes, for example `pest --parallel --processes=2`. If a coverage run runs out of memory, raise `SAIL_WT_APP_MEM` before creating the worktree, or edit its `compose.override.yaml`.

## Environment variables

| Variable | Effect |
| --- | --- |
| `SAIL_WT_ENV_FROM` | `.env` to copy values from; defaults to the main checkout's `.env`; `example` copies nothing |
| `SAIL_WT_PHP` | Force the PHP version used to pick the bootstrap image, e.g. `8.4` |
| `SAIL_WT_NO_SEED` | `1` runs `migrate` without `--seed` |
| `SAIL_WT_LIMITS` | `0` skips `compose.override.yaml` |
| `SAIL_WT_APP_CPUS`, `SAIL_WT_APP_MEM`, `SAIL_WT_DB_CPUS`, `SAIL_WT_DB_MEM`, `SAIL_WT_SVC_CPUS`, `SAIL_WT_SVC_MEM`, `SAIL_WT_PHP_WORKERS` | Resource caps; see above |

## Front end

Node dependencies are not installed. The success message prints the install and dev commands for the project's package manager. It picks pnpm, yarn or bun from the lockfile, and npm otherwise. For example:

```bash
./vendor/bin/sail pnpm install                            # or npm / yarn
./vendor/bin/sail pnpm run dev --port <VITE_PORT> --strictPort
```

You have to pass `--port`: Sail publishes `VITE_PORT:VITE_PORT`, but Vite inside the container listens on 5173 unless told otherwise. With npm the flags go after `--` (`npm run dev -- --port <VITE_PORT>`).

## Notes

- The `sail-<php>/app` image is shared between every worktree and every project on the same PHP version, so it is built once. A project that customizes its Dockerfile should give the image its own name in the compose file. The Composer step then no longer finds `sail-<php>/app` and uses `composer:2` with `--ignore-platform-reqs`, which still works.
- The resource caps are skipped, with a warning, when `.env` sets `SAIL_FILES` or `COMPOSE_FILE`: with either of those, docker compose doesn't load `compose.override.yaml`.
- In exclusive mode the main checkout's stack is stopped too. `sail-wt start <main-folder-name>`, or `sail up -d` in the main checkout, brings it back.
- `rm` deletes the database volumes and any uncommitted files in the worktree.
