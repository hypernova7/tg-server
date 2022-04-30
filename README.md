# Deploy Docker Container to Heroku with [Telegram Bot API](https://github.com/tdlib/telegram-bot-api) and NGINX

### Inspired on [aiogram](https://github.com/aiogram/telegram-bot-api)

## Steps

**IMPORTANT!!** To complete these steps you need to install Docker. Please see [Install Docker Engine](https://docs.docker.com/engine/install/)


### Clone this repository

```bash
git clone https://github.com/hypernova7/tg-server.git
cd tg-server
```
### Create a Heroku app

```bash
heroku apps:create <heroku-app-name>
```

### Add required environmet vars

```bash
heroku config:add TELEGRAM_API_ID=<api-id> TELEGRAM_API_HASH=<api-hash> -a <heroku-app-name>
# NOTE: To pass extra arguments to telegram-bot-api, you can add the environment var EXTRA_ARGS
heroku config:add EXTRA_ARGS="--proxy=<proxy> --local" -a <heroku-app-name>
```

### Push container to heroku

```bash
# Sign In into Container Registry
heroku container:login
# Update, push and deploy your Docker container to heroku
# NOTE: Maybe you need to install `make`
make release appname=<heroku-app-name>
```

# Any issue?

### Please open a new issue https://github.com/hypernova7/tg-server/issues