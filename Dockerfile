# File Hunter - Docker image
# https://github.com/zen-logic/file-hunter
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Download and extract the release tarball (bundles server, agent, core, and static assets)
ARG VERSION=1.2.12
RUN curl -fSL "https://github.com/zen-logic/file-hunter/releases/download/v${VERSION}/filehunter-${VERSION}.tar.gz" \
    -o /tmp/filehunter.tar.gz \
    && tar xzf /tmp/filehunter.tar.gz --strip-components=1 -C /app \
    && rm /tmp/filehunter.tar.gz

RUN pip install --no-cache-dir -r requirements.txt

# The launcher expects a relative "data/" dir under /app.
# Symlink it to /data so the DB and agent config live on the mounted volume.
RUN mkdir -p /data && ln -s /data /app/data

# Pre-create config that stores DB in data/ (-> /data via symlink);
# the launcher handles agent_config.json during preflight.
COPY config.json /app/config.json

RUN chmod +x filehunter

EXPOSE 8000

CMD ["./filehunter"]
