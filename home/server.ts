import { createReadStream } from 'node:fs';
import { basename, join, normalize } from 'node:path';
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

const setResponseHeader = (event: H3Event<EventHandlerRequest>, name: string, value: string) =>
  event.res.headers.set(name, value);

const authHandler = async (
  event: H3Event<EventHandlerRequest>,
  authorization: string | null,
  bot_token: string | undefined
) => {
  try {
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
    if (payload.bot_token !== undefined && payload.bot_token !== bot_token) {
      throw new HTTPError({
        status: 401,
        statusText: 'Unauthorized',
        message: 'Invalid bot token'
      });
    }
  } catch {
    throw new HTTPError({
      status: 401,
      statusText: 'Unauthorized',
      message: 'Invalid auth token'
    });
  }
};

app.all('/**', async event => {
  const headers = event.req.headers;
  const json = await readBody(event);
  const method = event.req.method as Method;
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

  const work_dir = TELEGRAM_WORK_DIR ? normalize(join(TELEGRAM_WORK_DIR, bot_token, '/')) : '';
  const isFileRoute = url.includes('/file');

  if (!isFileRoute) {
    await authHandler(event, authorization, bot_token);
  }

  if (!isFileRoute) {
    setResponseHeader(event, 'Content-Type', 'application/json');

    const res = (await got(url, {
      throwHttpErrors: false,
      headers: {
        authorization: authorization as string,
        'content-type': headers.get('content-type') as string,
        'user-agent': headers.get('user-agent') as string
      },
      searchParams,
      method,
      json,
      timeout: { request: 10_000 }
    }).json()) as Record<string, any>;

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
    const file_path = normalize(join(work_dir, path_parts2.join('/')));

    if (!file_path.startsWith(work_dir)) {
      throw new HTTPError({
        status: 400,
        statusText: 'Bad request',
        message: 'Invalid file path'
      });
    }

    const { ext, mime } = (await fileTypeFromFile(file_path)) ?? {
      ext: 'bin',
      mime: 'application/octet-stream'
    };
    setResponseHeader(event, 'Content-Type', mime);
    setResponseHeader(
      event,
      'Content-Disposition',
      `attachment; filename=${basename(file_path)}.${ext}`
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
