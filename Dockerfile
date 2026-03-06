# File Hunter - Docker image
# https://github.com/zen-logic/file-hunter
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone file-hunter (REF can be branch name, e.g. main, or full commit SHA)
ARG REPO=https://github.com/zen-logic/file-hunter.git
ARG REF=main
RUN git init && git remote add origin "${REPO}" \
    && git fetch --depth 1 origin "${REF}" && git checkout "${REF}" \
    && rm -rf .git

# Install runtime deps only (exclude dev tools like ruff)
RUN pip install --no-cache-dir \
    starlette \
    "uvicorn[standard]" \
    aiosqlite \
    xxhash \
    python-multipart \
    httpx

# Database and config will live in /data (mounted volume)
RUN mkdir -p /data

# Use config that stores DB in /data for persistence
COPY config.json /app/config.json

EXPOSE 8000

# Bind to all interfaces so the app is reachable from outside the container
CMD ["python", "-m", "file_hunter", "--host", "0.0.0.0", "--port", "8000"]
