"""
  Proxy to restrict bots that are not owned by you
"""
from os import environ as env
from typing import Callable
from requests import request as got, codes, Response as reqResponse
from flask import Flask, abort, request as req, send_file
from flask.wrappers import Response


app = Flask(__name__)
allowedBotTokens = env.get('ALLOWED_BOT_TOKENS', '').split('\n')
excludedHeaders = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']


def sanitize(var:str):
  return var.replace('bot', '')


def is_restricted(token:str):
  if token not in allowedBotTokens:
    return True
  return False


def get_headers(res:reqResponse):
  return [
    (name, value) for (name, value) in res.raw.headers.items()
      if name.lower() not in excludedHeaders
  ]


def request(req):
  return got(
    method=req.method,
    allow_redirects=False,
    url=req.url.replace(req.host_url, 'http://127.0.0.1:8081/'), # send all request to telegram-bot-api local server, don't modify
    headers={key: value for (key, value) in req.headers if key != 'Host'},
    cookies=req.cookies,
    data=req.get_data()
  )

@app.route('/file/<path:u_path>')
def file(u_path):
  token, *__, filename = u_path.split('/')
  token = sanitize(token)

  if is_restricted(token):
    return abort(403)

  """ Check if file exists remotelly for more faster """
  res = request(req)

  if res.status_code == codes.ok:
    return send_file(
      path_or_file=f'/{sanitize(u_path)}',
      mimetype=res.headers['Content-Type'],
      download_name=filename,
      as_attachment=True
    )
  else:
    return abort(404)


@app.route('/', defaults={'u_path': ''})
@app.route('/<path:u_path>')
def api(u_path):
  token, *__ = u_path.split('/')
  token = sanitize(token)

  if is_restricted(token):
    return abort(403)

  res = request(req)
  return Response(
    response=res.content,
    status=res.status_code,
    headers=get_headers(res)
  )

if __name__ == '__main__':
  app.run(port=8282)