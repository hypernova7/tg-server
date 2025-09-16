<h1 align="center">Deploy your own <a href="https://github.com/tdlib/telegram-bot-api">Telegram Bot API</a></h1>
<p align="center">
  <b>Based on <a href="https://github.com/aiogram/telegram-bot-api">aiogram</a></b>
</p>

<p align="center">
  <a href="https://github.com/hypernova7/tg-server/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/hypernova7/tg-server/ci.yml?colorA=363a4f&colorB=cdd6f4&logo=github&style=for-the-badge&branch=v2" alt="Build Status"></a>
  <a href="https://github.com/hypernova7/tg-server/issues"><img src="https://img.shields.io/github/issues/hypernova7/tg-server?colorA=363a4f&colorB=fab387&logo=github&style=for-the-badge" alt="Issues"></a>
  <a href="https://github.com/hypernova7/tg-server/contributors"><img src="https://img.shields.io/github/contributors/hypernova7/tg-server?colorA=363a4f&colorB=cba6f7&logo=github&style=for-the-badge" alt="Contributors"></a>
  <a href="https://github.com/hypernova7/tg-server/stargazers"><img src="https://img.shields.io/github/stars/hypernova7/tg-server?colorA=363a4f&colorB=f5e0dc&logo=github&style=for-the-badge" alt="Stars"></a>
</p>
<p align="center">
  <a href="https://hub.docker.com/r/tgserver/tgserver"><img src="https://img.shields.io/docker/v/tgserver/tgserver?colorA=363a4f&colorB=cdd6f4&logo=docker&logoColor=fff&sort=semver&style=for-the-badge" alt="Docker Image Version"></a>
  <a href="https://hub.docker.com/r/tgserver/tgserver"><img src="https://img.shields.io/docker/image-size/tgserver/tgserver?colorA=363a4f&colorB=94e2d5&label=size&logo=docker&logoColor=fff&sort=semver&style=for-the-badge" alt="Dcoker Image Size"></a>
  <a href="https://hub.docker.com/r/tgserver/tgserver"><img src="https://img.shields.io/docker/pulls/tgserver/tgserver?colorA=363a4f&colorB=b4befe&label=pulls&logo=docker&logoColor=fff&sort=semver&style=for-the-badge" alt="Docker Image Pulls"></a>
  <a href="https://hub.docker.com/r/tgserver/tgserver"><img src="https://img.shields.io/docker/stars/tgserver/tgserver?colorA=363a4f&colorB=f9e2af&label=stars&logo=docker&logoColor=fff&sort=semver&style=for-the-badge" alt="Docker Image Stars"></a>
</p>

----

## :sparkles: Features

- Single token with `Bearer Authentication`
- Easy deploy for your own [telegram-bot-api](https://github.com/tdlib/telegram-bot-api) API server
- Increase bot API [limits](https://core.telegram.org/bots/api#using-a-local-bot-api-server)

> [!NOTE]
> Before deploy, please read [this](https://github.com/tdlib/telegram-bot-api/#moving-a-bot-from-one-local-server-to-another)

----

# Deploy

Create a directory

```bash
mkdir tgserver
cd tgserver
```

Copy or create the docker-compose.yml file in your tgserver directory

```yml
name: tgserver

services:
  api:
    image: tgserver/tgserver:latest
    env_file: .env
    restart: always
    ports:
      - '8080:8080'
    healthcheck:
      test: [CMD, curl, -f, 'http://127.0.0.1:8080/healthcheck']
    volumes:
      - file:/file

volumes:
  file: {}
```

____

## Environments

Create a .env file on your tgserver directory

```
TELEGRAM_API_ID=<api-id>                           # (required) API ID
TELEGRAM_API_HASH=<api-hash>                       # (required) API HASH
TELEGRAM_API_SECRET=<your-api-secret>              # (required) Add API Secret for most security
TELEGRAM_API_STATS_PATH=<my-secret-stats-path>     # (optional) Secret path for bot API stats (Stats contain bot tokens)
TELEGRAM_WORK_DIR=<files-dir>                      # (optional) File serve path
EXTRA_ARGS=--local                                 # (optional) Pass extra arguments to telegram-bot-api command
```

----

## :bug: Any issue?

### Please [open a new issue](https://github.com/hypernova7/tg-server/issues)
