import { createReadStream } from 'node:fs';
import { join } from 'node:path';
import process from 'node:process';
import { fileTypeFromFile } from 'file-type';
import got, { type Method } from 'got';
import { H3, HTTPError, readBody, serve, type EventHandlerRequest, type H3Event } from 'h3';
import { jwtVerify, type JWTPayload, type JWTVerifyResult } from 'jose';

const { TELEGRAM_API_SECRET, TELEGRAM_WORK_DIR } = process.env;

if (!TELEGRAM_API_SECRET) throw new Error('Missing TELEGRAM_API_SECRET');

const app = new H3();

const verifyJWToken = (token: string, secret: string): Promise<JWTVerifyResult<JWTPayload>> =>
  jwtVerify(token, new TextEncoder().encode(secret));
const setResponseHeader = (event: H3Event<EventHandlerRequest>, name: string, value: string) =>
  event.res.headers.set(name, value);

// Example to encrypt your bot token
// import { SignJWT, type JWTPayload, type JWTVerifyResult } from 'jose';
//
// const signJWT = (payload: JWTPayload, secret: string, expireIn: string) => {
//   return new SignJWT(payload)
//     .setProtectedHeader({ alg: 'HS256' })
//     .setIssuedAt()
//     .setExpirationTime(expireIn)
//     .sign(new TextEncoder().encode(secret));
// };

// console.log(await signJWT({
//   bot_token: 'Your bot token'
// }, TELEGRAM_API_SECRET, '12h'));

app.all('/**', async event => {
  const json = await readBody(event);
  const method = event.req.method as Method;
  const headers = event.req.headers as any;
  const { host, pathname } = new URL(event.req.url);
  const searchParams = event.url.searchParams;
  const authorization = headers.get('authorization');
  const url = event.req.url.replace(host, `127.0.0.1:8081`);
  const path_parts = pathname.split('/').filter(p => p?.length > 0);
  const bot_token = path_parts.find(p => p.startsWith('bot'))?.replace('bot', '');

  if (!bot_token) {
    throw new HTTPError({
      status: 400,
      statusText: 'Bad request',
      message: 'Not bot token provided'
    });
  }

  const work_dir = TELEGRAM_WORK_DIR ? join(TELEGRAM_WORK_DIR, bot_token, '/') : '';

  try {
    if (!url.includes('/file')) {
      if (!authorization?.startsWith('Bearer')) {
        setResponseHeader(event, 'Content-Type', 'application/json');
        throw new HTTPError({
          status: 401,
          statusText: 'Unauthorized',
          message: 'Missing auth token'
        });
      }
      const token = authorization.replace('Bearer', '').trim();
      const { payload }: { payload: Record<string, any> } = await verifyJWToken(
        token,
        TELEGRAM_API_SECRET
      );
      if (!payload.bot_token?.includes(bot_token)) {
        throw new HTTPError({
          status: 401,
          statusText: 'Unauthorized',
          message: 'Invalid bot token'
        });
      }
    }
  } catch {
    throw new HTTPError({
      status: 401,
      statusText: 'Unauthorized',
      message: 'Invalid auth token'
    });
  }

  const res = (await got(url, {
    throwHttpErrors: false,
    searchParams,
    headers,
    method,
    json
  }).json()) as Record<string, any>;

  if (!url.includes('/file')) {
    setResponseHeader(event, 'Content-Type', 'application/json');

    if (res.error_code) {
      throw new HTTPError({
        status: res.error_code,
        statusText: 'Bad request',
        message: res.description
      });
    }

    if (res.result?.file_path?.startsWith(work_dir)) {
      res.result.file_path = res.result.file_path.replace(work_dir, '');
    }

    return res;
  } else if (path_parts.length > 2) {
    const [, , ...path_parts2] = path_parts;
    const file_path = join(work_dir, path_parts2.join('/'));
    const { ext, mime } = (await fileTypeFromFile(file_path)) ?? {
      ext: 'bin',
      mime: 'application/octet-stream'
    };
    setResponseHeader(event, 'Content-Type', mime);
    setResponseHeader(
      event,
      'Content-Disposition',
      `attachment; filename=${path_parts.pop()}.${ext}`
    );
    return createReadStream(file_path);
  } else {
    throw new HTTPError({
      status: 400,
      statusText: 'Bad request',
      message: 'File path not provided'
    });
  }
});

serve(app, { port: 8082 });
