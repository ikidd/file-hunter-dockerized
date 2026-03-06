# File Hunter (Docker)

Docker setup for [File Hunter](https://github.com/zen-logic/file-hunter) — catalog, deduplicate, and consolidate your archive storage.

## Quick start

```bash
cp .env.example .env
docker compose up -d
```

Then open **http://localhost:8000** in your browser. On first launch, create your user account in the setup screen.

## Build

```bash
docker compose build
# or
docker build -t file-hunter:latest .
```

## Run with Docker Compose

- **Start:** `docker compose up -d`
- **Stop:** `docker compose down`
- **Logs:** `docker compose logs -f filehunter`

Data is stored in the bind-mounted directory (default `./data`) and persists across restarts.

## Configuration (.env)

| Variable | Default | Description |
|----------|---------|-------------|
| `FILEHUNTER_DATA` | `./data` | Host path for database and app data (bind mount). |
| `FILEHUNTER_PORT` | `8000` | Host port to publish. |
| `FILE_HUNTER_DEMO` | — | Set to `1` to seed demo data on first run. |

## Run with Docker only

```bash
docker run -d --name file-hunter -p 8000:8000 -v "$(pwd)/data:/data" file-hunter:latest
```

## Cataloging host directories

To scan folders from your host inside the container, add a bind mount in `docker-compose.yml`:

```yaml
volumes:
  - ${FILEHUNTER_DATA:-./data}:/data
  - /media/drives:/locations:ro   # read-only mounts to catalog
```

Then in File Hunter add a location such as `/locations/backup-disk`.

## Demo mode

Set in your `.env`:

```
FILE_HUNTER_DEMO=1
```

Then run once; the database will be seeded on first start.

## Requirements

- Docker and Docker Compose
- Image is based on `python:3.12-slim` and pulls File Hunter from GitHub at build time

## CI/CD and GitHub

A GitHub Actions workflow builds and pushes the image to GHCR on every push to `main` and **daily** (to pick up upstream [zen-logic/file-hunter](https://github.com/zen-logic/file-hunter) updates). See [GITHUB_SETUP.md](GITHUB_SETUP.md) to create the repo, push this code, and use the published image.

## License

File Hunter is MIT licensed by [Zen Logic Ltd](https://zenlogic.co.uk). This Docker packaging is provided as-is.
