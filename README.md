# Deploy Docker Container to Heroku with [Telegram Bot API](https://github.com/tdlib/telegram-bot-api) and NGINX + uWSGI support


### Inspired on [aiogram](https://github.com/aiogram/telegram-bot-api)
----


## :sparkles: Features

- Zero config
- Bot restrictions
- [telegram-bot-api](https://github.com/tdlib/telegram-bot-api) easy build
- Automated updates and deployment with Github Actions
- Increase API bot [limits](https://core.telegram.org/bots/api#using-a-local-bot-api-server)
- Your own API endpoint(`https://yourdomain.com/bot<token>/getMe`)

## :point_down: Steps

> **IMPORTANT!!** To complete these steps you need to install [Docker Engine](https://docs.docker.com/engine/install/), [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli).


### Clone this repository

```bash
git clone --recursive https://github.com/hypernova7/tg-server.git
cd tg-server
```


### Create a Heroku app

```bash
# Sign In on heroku
heroku auth:login
heroku apps:create <heroku-app-name>
```


### Add required environmet vars

```bash
# List your bot-ids seprate by commas so that
# only your bots can use the API `<bot-id>:AABBCdfghijklmopqrstuvwxyz1234567890`
heroku config:add ALLOWED_BOT_IDS=<bot-id>,<bot-id>,<bot-id> -a <heroku-app-name>
heroku config:add TELEGRAM_API_ID=<api-id> TELEGRAM_API_HASH=<api-hash> -a <heroku-app-name>
# NOTE: To pass extra arguments to telegram-bot-api, you can add the environment var EXTRA_ARGS
heroku config:add EXTRA_ARGS="--proxy=<proxy> --local" -a <heroku-app-name>
```
> **Optionally,** you can add full-tokens to ALLOWED_BOT_IDS, if you want to avoid exposing your token when sharing links to your bot files.
> Example: `ALLOWED_BOT_IDS=<bot-id>,<bot-id>:<bot-token>,<bot-id>`

### Push container to heroku

```bash
# Sign In into Container Registry
heroku container:login
# Update, push and deploy your Docker container to heroku
# NOTE: Maybe you need to install `make`
make release appname=<heroku-app-name>
# or run directly
heroku container:push web -a <heroku-app-name>
heroku container:release web -a <heroku-app-name>
```

### :information_source: After the deployment process is finished please read [this](https://github.com/tdlib/telegram-bot-api/#moving-a-bot-from-one-local-server-to-another)
____



## :zap: Automated deployment with Github Actions


### You can deploy your Docker Container to Heroku in a fully automated way, thanks to the power of Github Actions.

This repository already provide a pre-configured Github Action, only you need to clone this repo into a new private repository. Then simply add the following secrets in `Settings > Secrets > Actions`.


> **NOTE**: The Github Action provided in this repository is scheduled to auto-run every day, and auto-deploy on any updates to the telegram-bot-api submodules. _Optionally, you can add `FORCE_DEPLOY=true` to your repository secrets to force deployment **but be careful, this Github Action is scheduled to auto-run every day at 12am UTC**_.

> **IMPORTANT**: For private repositories, please enable read and write permissions on `Settings > Actions > General > Workflows permissions` for auto commits, to keep your repository up to date on every telegram-bot-api update.


```
HEROKU_API_KEY=<heroku-api-key>
HEROKU_APP_NAME=<heroku-app-name>
```


## :bug: Any issue?

### Please [open a new issue](https://github.com/hypernova7/tg-server/issues)
