# file-hunter-dockerized

Docker image and Compose setup for [File Hunter](https://github.com/zen-logic/file-hunter) (catalog, deduplicate, and consolidate archive storage).

## Quick start

```bash
cp .env.example .env
docker compose up -d
```

Open **http://localhost:8000** and create your user on first launch.

## Image

Pre-built image from this repo (see [LATEST_BUILD.md](LATEST_BUILD.md) for current upstream SHA and tags):

```bash
docker pull ghcr.io/ikidd/file-hunter-dockerized:latest
```

Use `:latest` or a commit tag (e.g. `:a1b2c3d`) from [LATEST_BUILD.md](LATEST_BUILD.md) to pin upstream.

## Config

| Variable | Default | Description |
|----------|---------|-------------|
| `FILEHUNTER_IMAGE` | `ghcr.io/ikidd/file-hunter-dockerized:latest` | Image to run. |
| `FILEHUNTER_DATA` | `./data` | Host path for DB (bind mount). |
| `FILEHUNTER_PORT` | `8000` | Host port. |
| `FILEHUNTER_MOUNT_HOST` | `1` | Enable full host access when set (see below). |
| `FILEHUNTER_HOST_PATH` | `/` | Host path mounted read-only at `/host` in the container. Set to `/` for full host; leave empty to disable (only `/tmp` at `/host`). |
| `FILE_HUNTER_DEMO` | — | Set to `1` to seed demo data. |

With host access enabled (default), add locations in File Hunter under **/host** (e.g. `/host/home`, `/host/media`) to catalog the host filesystem.

## Triggering a build

- **Scheduled:** Daily at 00:00 UTC the workflow checks the **latest upstream GitHub release** of [zen-logic/file-hunter](https://github.com/zen-logic/file-hunter). A new image is built and pushed **only when that release resolves to a new commit** (same idea as [cursor-linux-release](https://github.com/ikidd/cursor-linux-release), which skips work when there is nothing new).
- **Manual:** **Actions → Build and push image → Run workflow** runs the same release check; it still builds only if the latest upstream release is newer than the one recorded in this repo.
- **Optional event-driven trigger:** A `repository_dispatch` event of type `upstream_release` can start this workflow immediately; behavior is unchanged otherwise (it still resolves and builds from the release's commit SHA).

When an image is published, [LATEST_BUILD.md](LATEST_BUILD.md) records the upstream SHA and tags. Timestamps below are updated every run.

## More

- [zen-logic/file-hunter](https://github.com/zen-logic/file-hunter) — Upstream app.



## 📅 Build status

- **⏳ Last Released On**: 2026-03-22 00:12:46 UTC
- **🔄 Last Run**: 2026-03-22 00:12:46 UTC
- **🏷️ Upstream Latest Release**: [`v1.2.10`](https://github.com/zen-logic/file-hunter/releases/tag/v1.2.10)
- **🧭 Decision**: upstream-release-commit-changed
- **📦 Upstream in image**: `97873b6` (`ghcr.io/ikidd/file-hunter-dockerized:97873b6`)
