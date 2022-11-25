# Deploy your own [Telegram Bot API](https://github.com/tdlib/telegram-bot-api)


**Inspired on [aiogram](https://github.com/aiogram/telegram-bot-api)**
----


## :sparkles: Features

- Zero config
- Restricted mode (`Only your bots will be able to use your bot API`)
- [telegram-bot-api](https://github.com/tdlib/telegram-bot-api) easy build
- Continuous Deployment with Github Actions
- Increase API bot [limits](https://core.telegram.org/bots/api#using-a-local-bot-api-server)
- Your own API endpoint(`https://yourdomain.com/bot<token>/getMe`)
- Deploy your bot API to [Heroku](https://heroku.com) or [fly.io](https://fly.io)

## :point_down: Steps

> **IMPORTANT!!** You need to install [Docker Engine](https://docs.docker.com/engine/install/), [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) or [fly.io CLI](https://fly.io/docs/hands-on/install-flyctl/).


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

____

> **Optionally,** you can add full-tokens to ALLOWED_BOT_IDS, if you want to avoid exposing your token when sharing links to your bot files. For example: `ALLOWED_BOT_IDS=<bot-id>,<bot-id>:<bot-token>,<bot-id>`

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

> **NOTE**: Before deploying, please read [this](https://github.com/tdlib/telegram-bot-api/#moving-a-bot-from-one-local-server-to-another)
____



## :zap: Continuous Deployment with Github Actions.


### Setup secrets

This repository already provides pre-configured Workflows for Heroku(`.github/workflows/heroku.yml`) and fly.io(`.github/workflows/flyio.yml`). You only need to setup the following secrets on `Settings > Secrets > Actions`.


> **NOTE**: Workflows are scheduled to run every day at 12am UTC, and auto-deploy on any updates to the telegram-bot-api submodule. _Optionally, Add `FORCE_DEPLOY=true` to your repository secrets or `_deploy_` to your specific commit message to force the deployment. **But remember, these Workflows runs everyday**_.

> **IMPORTANT**: For private repositories, please enable read and write permissions in `Settings > Actions > General > Workflows permissions` for auto commits, to keep telegram-bot-api submodules updated.


#### For heroku:

```
HEROKU_API_KEY=<heroku-api-key>
HEROKU_APP_NAME=<heroku-app-name>
```

#### For fly.io:

```
FLY_API_TOKEN=<your-fly-api-token>
```

## Special thanks to

[![@sayyid5416](https://github.com/sayyid5416.png?size=50)](https://github.com/sayyid5416)

## :bug: Any issue?

### Please [open a new issue](https://github.com/hypernova7/tg-server/issues)
