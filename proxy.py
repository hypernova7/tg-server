"""
  Credits to https://github.com/sayyid5416
  Proxy to restrict bots that are not owned by you
"""
from typing import Union, Dict
from os import environ as env, path
from requests import request as got
from flask import Flask, request as req, send_file
from flask.json import jsonify
from flask_cors import CORS

# Init
app: Flask = Flask(__name__)
CORS(app)
errors = {
    '401': {'ok': False, 'error_code': 401, 'description': 'Unauthorized'},
    '404': {'ok': False, 'error_code': 404, 'description': 'Not found'}
}

# [Parsing] Allowed bots data from env
# Example: `ALLOWED_BOT_IDS=botid,botid:bottoken,botid,...`
allowedBotIds = env.get('ALLOWED_BOT_IDS', '').split(',')
# allowedBots = {botid: bot-token}
allowedBots: Dict[str, Union[str, None]] = {}
for i in allowedBotIds:
    if ':' in i:
        botID, botToken = i.split(':', 1)
    else:
        botID, botToken = i, None
    allowedBots.update({botID: botToken})


def sanitize(token: Union[str, None]):
    """ Remove bot prefix from URL """
    return token if token is None else token.replace('bot', '', 1)


def is_unauthorized(token: Union[str, None]):
    """ Returns True, if bot is unauthorized """
    bot_id = token.split(':')[0] if token else None
    return token is None or bot_id not in allowedBotIds


def make_error(code: int):
    """ Make proper API errors """
    return jsonify(errors[str(code)]), code


def get_path_data(u_path: Union[str, None]):
    """ Returns the filename and token from the path """
    path_parts = u_path.split('/') if u_path else [None]
    filename, token = path_parts[-1], path_parts[0]
    return filename, sanitize(token)


def request():
    """ Send all HTTP request to telegram-bot-api local server """
    # Capture data before cleaning
    rdata = req.get_data()
    # Fix Content-Type header when opening URL in browser
    content_type = req.headers[
        'Content-Type'
    ] if 'Content-Type' in req.headers else 'application/json'

    return got(
        method=req.method,
        url=req.url.replace(req.host_url, 'http://127.0.0.1:8081/'),
        headers={'Content-Type': content_type, 'Connection': 'keep-alive'},
        params=req.args,
        data=rdata
    )


@app.route('/file/<path:u_path>', methods=['GET'])
def file(u_path: str):
    """ Handle local files """
    filename, token = get_path_data(u_path)

    if is_unauthorized(token):
        return make_error(401)

    # Getting correct filepath for the file
    bot_id = token.split(':', 1)[0]
    # ':' signifies if a token is present or not
    if f'{bot_id}:' not in token:
        bot_token = allowedBots.get(bot_id)
        if bot_token:
            u_path = u_path.replace(bot_id, f'{bot_id}:{bot_token}', 1)
    file_path = f'/file/{sanitize(u_path)}'

    # Check if file exists
    if not path.exists(file_path):
        return make_error(404)

    return send_file(
        path_or_file=file_path,
        mimetype='application/octet-stream',
        download_name=filename,
        as_attachment=True
    )


@app.route('/', defaults={'u_path': ''})
@app.route('/<path:u_path>', methods=['GET', 'POST'])
def api(u_path: str):
    """ Handle all API request """
    __, token = get_path_data(u_path)

    if is_unauthorized(token):
        return make_error(401)

    res = request()
    return jsonify(res.json()), res.status_code


if __name__ == '__main__':
    app.run(port=8282)
