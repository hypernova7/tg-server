<h1 align="center">Deploy your own <a href="https://github.com/tdlib/telegram-bot-api">Telegram Bot API</a></h1>
<p align="center">
  <b>Inspired on <a href="https://github.com/aiogram/telegram-bot-api">aiogram</a></b>
</p>

<p align="center">
  <a href="https://github.com/hypernova7/tg-server/actions/workflows/ci.yml"><img src="https://badge.deta.dev/hypernova7/tg-server/ci.yml?colorA=363a4f&greenColor=a6e3a1&redColor=f38ba8&orangeColor=fab387&otherColor=cdd6f4&label=build&logo=github&style=for-the-badge" alt="Build Status"></a>
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

- Zero config
- Restricted mode (`Only your bots will be able to use your bot API`)
- Easy build of [telegram-bot-api](https://github.com/tdlib/telegram-bot-api)
- Continuous Deployment with Github Actions
- Increase bot API [limits](https://core.telegram.org/bots/api#using-a-local-bot-api-server)
- Your own API endpoint(`https://yourdomain.com/bot<token>/getMe`)
- Deploy your bot API to [Heroku](https://heroku.com) or [fly.io](https://fly.io)

## :point_down: Steps

> **IMPORTANT**: Need to install [Docker Engine](https://docs.docker.com/engine/install/), [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) or [fly.io CLI](https://fly.io/docs/hands-on/install-flyctl/).


### Clone this repository

```bash
git clone https://github.com/hypernova7/tg-server.git
cd tg-server
git submodule update --init --recursive
```


### Create a Heroku app

```bash
# Sign In on heroku
heroku auth:login
heroku apps:create <heroku-app-name>
```

**or**

### Create a fly.io app
```bash
flyctl auth signup
flyctl auth login
flyctl launch # This command will generate a fly.toml file (Please see this: https://fly.io/docs/reference/configuration/#fly-toml-line-by-line)
```


### Add these environment vars to your app

#### Using Heroku CLI

```bash
# List your bot-ids seprate by commas so that
# only your bots can use the API `<bot-id>:AABBCdfghijklmopqrstuvwxyz1234567890`
heroku config:add ALLOWED_BOT_IDS=<bot-id>,<bot-id>,<bot-id> -a <heroku-app-name>
heroku config:add TELEGRAM_API_ID=<api-id> TELEGRAM_API_HASH=<api-hash> -a <heroku-app-name>
# NOTE: To pass extra arguments to telegram-bot-api, you can add the environment var EXTRA_ARGS
heroku config:add EXTRA_ARGS="--proxy=<proxy> --local" -a <heroku-app-name>
```

#### Using fly.io CLI

```bash
# List your bot-ids seprate by commas so that
# only your bots can use the API `<bot-id>:AABBCdfghijklmopqrstuvwxyz1234567890`
flyctl secrets set ALLOWED_BOT_IDS=<bot-id>,<bot-id>,<bot-id> -a <heroku-app-name>
flyctl secrets set TELEGRAM_API_ID=<api-id> TELEGRAM_API_HASH=<api-hash> -a <heroku-app-name>
# NOTE: To pass extra arguments to telegram-bot-api, you can add the environment var EXTRA_ARGS
flyctl secrets set EXTRA_ARGS="--proxy=<proxy> --local" -a <heroku-app-name>
```

> **NOTE**: Optionally and if required, you can set the SWAP_SIZE environment variable to setup swap, by default is disabled. Example: `SWAP_SIZE=51200K` (`51200K` = `50MB`) or `SWAP_SIZE=200M` (`200M` = `200MB`) or `SWAP_SIZE=4G` (`4GB` = `4GB`) or `SWAP_SIZE=8589934592` (`8589934592` = `8GB` in bytes)

____

> **Optionally** can add full-tokens to ALLOWED_BOT_IDS, if you want to avoid exposing your token when sharing links to your bot files. For example: `ALLOWED_BOT_IDS=<bot-id>,<bot-id>:<bot-token>,<bot-id>`

### Deploy to Heroku

```bash
# Sign In into Container Registry
heroku container:login
# Push and deploy Container
heroku container:push web -a <heroku-app-name>
heroku container:release web -a <heroku-app-name>
```

### Deploy to fly.io

```bash
flyctl deploy
# Run the following commands only once
# Since it allocates IP's as many as it runs
# Please see this https://fly.io/docs/flyctl/ips/#usage
flyctl ips allocate-v4
flyctl ips allocate-v6
```

> **IMPORTANT**: Before deploying, please read [this](https://github.com/tdlib/telegram-bot-api/#moving-a-bot-from-one-local-server-to-another)
____



## :zap: Continuous Deployment with Github Actions.


### Setup secrets

This repository already provides pre-configured Workflows for Heroku and fly.io. You only need to setup the following secrets on `Settings > Secrets > Actions`.


> **NOTE**: Workflows are scheduled to run every day at 12am UTC, and auto-deploy on any updates to the telegram-bot-api submodule. _Optionally, can add `FORCE_DEPLOY=true` to your repository secrets or `_deploy_` to your specific commit message to force the deployment. **But remember, these Workflows runs everyday**_.

> **IMPORTANT**: For private repositories, please enable read and write permissions in `Settings > Actions > General > Workflows permissions` for auto commits, to keep telegram-bot-api submodules updated if you want.


#### For heroku:

```
HEROKU_API_KEY=<heroku-api-key>
HEROKU_APP_NAME=<heroku-app-name>
```

#### For fly.io:

```
FLY_API_TOKEN=<your-fly-api-token>
```

## :sparkling_heart: Special thanks to

[![@sayyid5416](https://github.com/sayyid5416.png?size=50)](https://github.com/sayyid5416)

## :bug: Any issue?

### Please [open a new issue](https://github.com/hypernova7/tg-server/issues)
