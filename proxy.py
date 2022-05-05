"""
  Credits to https://github.com/sayyid5416
  Proxy to restrict bots that are not owned by you
"""
from typing import List
from os import environ as env
from requests import request as got
from flask import Flask, abort, request as req, send_file
from flask.wrappers import Response

app = Flask(__name__)
allowedBotIds = env.get('ALLOWED_BOT_IDS', '').split(',')
excludedHeaders = [
  'content-encoding',
  'content-length',
  'transfer-encoding',
  'connection'
]


def sanitize(token: str) -> str:
  return token.replace('bot', '')


def not_allowed(bot_id: str):
  return bot_id not in allowedBotIds


def get_headers(res):
  return [
    (name, value) for name, value in res.raw.headers.items()
    if name.lower() not in excludedHeaders
  ]


def unpack(source: List[str], target: int, default_value=None):
  num = len(source)
  if num < target:
    return [*source, *([default_value] * (target - len(source)))]
  if num > target:
    return source[0:target]
  return source


def get_path_data(path: str):
  token, *__, filename = unpack(path.split('/'), 3)
  token: str = sanitize(token)
  bot_id: str = token.split(':')[0]
  return bot_id, filename


def request():
  """ Send all HTTP request to telegram-bot-api local server, don't modify """
  return got(
    method='POST',
    allow_redirects=False,
    url=req.url.replace(req.host_url, 'http://127.0.0.1:8081/'),
    headers={key: value for (key, value) in req.headers if key != 'Host'},
    cookies=req.cookies,
    data=req.get_data()
  )


@app.route('/file/<path:u_path>')
def file(u_path: str):
  """ Handle local files """
  bot_id, filename = get_path_data(u_path)

  if not_allowed(bot_id):
    abort(403)

  # Check if file exists via HTTP request for more faster
  res = request()

  if res.status_code != 200:
    abort(404)

  return send_file(
    path_or_file=f'/{sanitize(u_path)}',
    mimetype=res.headers['content-type'],
    download_name=filename,
    as_attachment=True
  )


@app.route('/', defaults={'u_path': ''})
@app.route('/<path:u_path>')
def api(u_path: str):
  """ Handle all API request"""
  bot_id, *__ = get_path_data(u_path)

  if not_allowed(bot_id):
    abort(403)

  res = request()

  return Response(
    response=res.content,
    status=res.status_code,
    headers=get_headers(res)
  )


if __name__ == '__main__':
  app.run(port=8282)
