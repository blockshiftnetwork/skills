---
name: laravel-sail-worktrees
description: Creates, lists, starts, stops and removes git worktrees of a Laravel Sail project, each running as its own Docker stack with its own compose project name, free host ports, .env copied from the main checkout (development credentials included), Composer dependencies, and a migrated and seeded database, while limiting how much CPU and memory the stacks use. Use when the user wants to work on another branch in parallel, spin up a worktree, review or test a branch without touching their current checkout, run two Sail environments side by side, or stop and clean up worktree stacks in any project that uses Laravel Sail (compose.yaml with a laravel.test service).
---

# Laravel Sail worktrees

`scripts/sail-wt.sh` (next to this file) does all the work. Run it from inside the project's repository, either the main checkout or one of its worktrees. New worktrees are created beside the main checkout as `../<folder>`.

## Quick start

```bash
S=<this-skill-dir>/scripts/sail-wt.sh      # or `sail-wt` if installed on PATH
$S ls                                       # what exists, what runs, what it costs
$S feat-x feat/x --from origin/main --keep  # new branch from origin/main, other stacks untouched
$S stop feat-x                              # pause it; data is kept
$S rm feat-x --yes                          # only after the user confirmed
```

`create` takes about a minute once the Sail image is built and the Composer cache is warm, so give the command a timeout of 10 minutes. On a machine that has never built the project's Sail image, `sail up` builds it first, which can take longer, so run that first create in the background. At the end it prints the app URL, the ports, and the exact Vite command.

## Workflow: create a worktree

1. Run `$S ls` first and look at the STATE column.
2. **Decide `--keep`.** Without it, `create` and `start` stop every other stack, the main checkout's included, so a stack the user is working in goes down. If anything is running and the user hasn't said it may be stopped, pass `--keep` or ask them.
3. **Decide the base of a new branch.** It starts from the current HEAD unless you pass `--from <ref>`. When the user says "from main" or similar, use `--from origin/main`. Never base a new branch on the user's in-progress branch by accident. The new branch never tracks `<ref>`, so `git push -u origin <branch>` is safe.
4. Choose a folder name that says what the worktree is for. It must start with a letter or digit and may contain letters, digits, `.`, `_` and `-`. It becomes the compose project name.
5. Run the command and report the URL, path, branch and ports from its output.

Work inside the worktree with its own `./vendor/bin/sail`, never the main checkout's: each worktree is a separate compose project.

## Workflow: pause, resume, remove

- **Pause:** `$S stop <folder>` or `$S stop --all` stop the containers and keep their data. Prefer this when the user is done for now.
- **Resume:** `$S start <folder> [--keep]` follows the same `--keep` rule as create.
- **Remove:** `$S rm <folder>` deletes the containers, the **database volumes** and the worktree directory, including any uncommitted work in it. Before passing `--yes`, check `git -C ../<folder> status --short` and get the user's explicit confirmation. The branch survives; delete it only if the user asks.

## Credentials and real systems

The worktree's `.env` is the branch's `.env.example` with every value from the main checkout's `.env` copied on top. Only the per-worktree keys are then rewritten: ports, `APP_URL`, `COMPOSE_PROJECT_NAME`, `WWWUSER`/`WWWGROUP` and `PHP_CLI_SERVER_WORKERS`. This is deliberate, because integrations get tested against real sandbox systems. Point out to the user:

- **Webhooks:** a provider calls back one URL. Two worktrees on the same bot or app take the webhook from each other.
- **OAuth:** redirect URIs include the port, so a worktree on a new port needs that URI registered.
- **Database-stored secrets:** these don't come along, because each worktree gets a freshly seeded database.
- **Different source:** `SAIL_WT_ENV_FROM=<file>` copies from another file, and `SAIL_WT_ENV_FROM=example` copies nothing.

## When something fails

The script stops at the first error and prints the failing line. Fix the cause and don't retry blindly. A half-created worktree is removed with `$S rm <folder>` after checking it has nothing worth keeping.

Read [references/how-it-works.md](references/how-it-works.md) for:
- every step `create` takes, and how ports are allocated;
- the resource caps and the environment variables that tune them;
- the Composer bootstrap image;
- the Vite port;
- installing the command on PATH.
