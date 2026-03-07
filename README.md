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

- **Automatic:** Push to `main` or wait for the daily schedule (00:00 UTC).
- **Manual:** **Actions → Build and push image → Run workflow.**

After a successful run, [LATEST_BUILD.md](LATEST_BUILD.md) is updated with the upstream commit SHA and image links.

## More

- [GITHUB_SETUP.md](GITHUB_SETUP.md) — Repo setup and GHCR usage.
- [zen-logic/file-hunter](https://github.com/zen-logic/file-hunter) — Upstream app.
