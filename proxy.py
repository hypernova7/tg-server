"""
  Credits to https://github.com/sayyid5416
  Proxy to restrict bots that are not owned by you
"""
import os
from typing import List, Union
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
allowedBots = os.environ.get('ALLOWED_BOT_IDS', '').split(',')                    # botid,botid:bottoken,botid,....
allowedBotIds :dict[str, Union[str,None]] = {}                                    # {botid: bot-token}
for i in allowedBots:
  if ':' in i:    botID, botToken = i.split(':', 1)
  else:           botID, botToken = i, None
  allowedBotIds.update({botID: botToken})



def sanitize(token: Union[str, None]) -> str:
  return token if token is None else token.replace('bot', '', 1)


def is_unauthorized(token: Union[str,None]):
  """ Returns True, if bot is unauthorized """
  bot_id = token.split(':')[0] if token else None
  return bot_id not in allowedBotIds


def make_error(code: int):
  return jsonify(errors[str(code)]), code


def get_path_data(path: Union[str,None]):
  """ Returns the filename and token from the path """
  pathParts = path.split('/') if path else [None]
  filename, token = pathParts[-1], pathParts[0]
  return filename, sanitize(token)


def unpack(source: List[str], target: int, default_value=None):
  num = len(source)
  if num < target:
    return [*source, *([default_value] * (target - len(source)))]
  if num > target:
    return source[0:target]
  return source


def request():
  """ Send all HTTP request to telegram-bot-api local server """
  rdata = req.get_data()                                        # Capture data before cleaning
  content_type = 'application/json'                             # Fix Content-Type header when opening URL in browser

  if 'Content-Type' in req.headers:
    content_type = req.headers['Content-Type']

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
  if f'{bot_id}:' not in u_path:                           # ':' signifies if a token is present or not
    botToken = allowedBotIds.get(bot_id)
    if botToken: u_path = u_path.replace(bot_id, f'{bot_id}:{botToken}', 1)
  filePath = f'/file/{sanitize(u_path)}'

  # Check if file exists
  if not os.path.exists(filePath):
    return make_error(404)

  return send_file(
    path_or_file=filePath,
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
