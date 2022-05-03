"""
  Proxy to restrict bots that are not owned by you
"""
from re import sub
from os import environ as env
from requests import request as got, codes
from flask import Flask, abort, request as req, send_file
from flask.wrappers import Response

app = Flask(__name__)
allowedBotIds = env.get('ALLOWED_BOT_IDS', '').split(',')
excludedHeaders = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']

class Object(object):
  pass

def sanitize(token):
  return token.replace('bot', '')

def getPathData(path):
  o = Object()
  token, *__, filename = path.split('/')
  o.bot_id = sub(r'bot([\d]+):[\w]+', r'\1', token)
  o.token = sanitize(token)
  o.filename = filename
  return o

def isAllowed(bot_id):
  if bot_id not in allowedBotIds:
    return True
  return False

def headers(res):
  return [
    (name, value) for (name, value) in res.raw.headers.items()
      if name.lower() not in excludedHeaders
  ]

def request(req):
  return got(
    method=req.method,
    allow_redirects=False,
    url=req.url.replace(req.host_url, 'http://127.0.0.1:8081/'), # send all request to telegram-bot-api local server, don't modify
    headers={ key: value for (key, value) in req.headers if key != 'Host' },
    cookies=req.cookies,
    data=req.get_data()
  )

@app.route('/file/<path:u_path>')
def file(u_path):
  data = getPathData(u_path)

  if isAllowed(data.bot_id):
    return abort(403)

  """ Check if file exists remotelly for more faster """
  res = request(req)

  if res.status_code == codes.ok:
    return send_file(
      path_or_file=f'/{sanitize(u_path)}',
      mimetype=res.headers['content-type'],
      download_name=data.filename,
      as_attachment=True
    )
  else:
    return abort(404)

@app.route('/', defaults={'u_path': ''})
@app.route('/<path:u_path>')
def api(u_path):
  data = getPathData(u_path)

  if isAllowed(data.bot_id):
    return abort(403)

  res = request(req)

  return Response(
    response=res.content,
    status=res.status_code,
    headers=headers(res)
  )

if __name__ == '__main__':
  app.run(port=8282)