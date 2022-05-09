# Deploy Docker Container to Heroku with [Telegram Bot API](https://github.com/tdlib/telegram-bot-api) and NGINX + uWSGI


### Inspired on [aiogram](https://github.com/aiogram/telegram-bot-api)
----


## :sparkles: Features

- Zero config
- Bot restrictions
- [telegram-bot-api](https://github.com/tdlib/telegram-bot-api) easy buld
- Automated deployment with Github Actions
- Your own API endpoint(`https://yourdomain.com/bot<token>/getMe`) to have [extra features](https://github.com/tdlib/telegram-bot-api) that the original API does not provide

## :point_down: Steps

> **IMPORTANT!!** To complete these steps you need to install [Docker Engine](https://docs.docker.com/engine/install/), [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli).


### Clone this repository

```bash
git clone https://github.com/hypernova7/tg-server.git
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


## :zap: Automated deployment with Github Actions


### You can deploy your Docker Container to Heroku in a fully automated way, thanks to the power of Github Actions.

This repository already provides a pre-configured Github Action, you just need to clone and create a private repository with all the configuration provided in this repository for your Docker Container. Then simply add the following secrets in `repository settings > secrets` to your private repository.


> **NOTE**: The Github Action provided in this repository is scheduled to check for updates to the `telegram-bot-api` submodule and deploy if there are any changes every day. Optionally, you can add `FORCE_DEPLOY=true` to your repository secrets, to deploy the changes every time you push your own changes **but be careful, the Github Action is scheduled to run every day at 12am UTC**.


```
HEROKU_EMAIL=<heroku-email>
HEROKU_API_KEY=<heroku-api-key>
HEROKU_APP_NAME=<heroku-app-name>
```


## :bug: Any issue?

### Please [open a new issue](https://github.com/hypernova7/tg-server/issues)
