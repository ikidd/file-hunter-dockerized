# GitHub repo and workflow setup

## Create the repository

If **GitHub CLI** is not logged in (`gh auth login`) or `GH_TOKEN` is not set, create the repo on GitHub first, then add the remote and push:

```bash
# On GitHub: New repository → name: file-hunter-dockerized → Create (no need to add README)

# Then locally:
cd /path/to/file-hunter-dockerized
git remote add origin https://github.com/YOUR_USERNAME/file-hunter-dockerized.git
git push -u origin main
```

Otherwise, from this directory:

```bash
# Ensure you're in the project root
cd /home/ikidd/Projects/file-hunter-dockerized

# Create repo on GitHub (choose one)

# 1) Public repo, no description
gh repo create file-hunter-dockerized --public --source=. --push

# 2) Public repo with description and remote name
gh repo create file-hunter-dockerized --public --description "Docker image for zen-logic/file-hunter" --source=. --remote=origin --push

# 3) If the repo already exists on GitHub, just add remote and push
git init
git add .
git commit -m "Add Docker setup and GitHub workflow"
git remote add origin https://github.com/YOUR_USERNAME/file-hunter-dockerized.git
git branch -M main
git push -u origin main
```

You need [GitHub CLI](https://cli.github.com/) (`gh`) installed and logged in (`gh auth login`) for options 1–2.

## Workflow behavior

- **On push to `main`**  
  Builds the image with upstream `zen-logic/file-hunter` at `main` and pushes to GitHub Container Registry (GHCR).

- **Daily (00:00 UTC)**  
  Fetches the latest commit from `zen-logic/file-hunter` `main`, builds the image from that commit, and pushes. You get an image that tracks upstream.

- **Manual run**  
  Use **Actions → Build and push image → Run workflow** to trigger the same logic as the daily run.

## Container image

After the first successful run:

- **Image:** `ghcr.io/<your-username>/file-hunter-dockerized:latest`  
  Also tagged with the upstream commit short SHA, e.g. `ghcr.io/<your-username>/file-hunter-dockerized:a1b2c3d`.

- **Visibility:** The package is tied to the repo. Make it public under **Repo → Packages** or in the package’s **Package settings**.

## Permissions

The workflow uses the default `GITHUB_TOKEN` and only needs:

- **Contents:** read (checkout)
- **Packages:** write (push to GHCR)

No extra secrets are required for building and pushing to GHCR for the same repo.

## Using the image from GHCR

Once the package is public (or you’re logged in):

```bash
# Pull
docker pull ghcr.io/YOUR_USERNAME/file-hunter-dockerized:latest

# Or pin to an upstream commit
docker pull ghcr.io/YOUR_USERNAME/file-hunter-dockerized:a1b2c3d
```

In `docker-compose.yml` you can point to the GHCR image instead of building locally:

```yaml
services:
  filehunter:
    image: ghcr.io/YOUR_USERNAME/file-hunter-dockerized:latest
    # build: .   # remove or comment out to use pre-built image
```

Replace `YOUR_USERNAME` with your GitHub username (or org).
