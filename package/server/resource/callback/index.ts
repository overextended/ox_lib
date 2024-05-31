import { cache } from '../cache';

const pendingCallbacks: Record<string, (...args: any[]) => void> = {};
const callbackTimeout = GetConvarInt('ox:callbackTimeout', 60000);

onNet(`__ox_cb_${cache.resource}`, (key: string, ...args: any) => {
  const resolve = pendingCallbacks[key];
  delete pendingCallbacks[key];

  return resolve && resolve(...args);
});

export function triggerClientCallback<T = unknown>(
  eventName: string,
  playerId: number,
  ...args: any
): Promise<T> | void {
  let key: string;

  do {
    key = `${eventName}:${Math.floor(Math.random() * (100000 + 1))}:${playerId}`;
  } while (pendingCallbacks[key]);

  emitNet(`__ox_cb_${eventName}`, playerId, cache.resource, key, ...args);

  return new Promise<T>((resolve, reject) => {
    pendingCallbacks[key] = resolve;

    setTimeout(reject, callbackTimeout, `callback event '${key}' timed out`);
  });
}

export function onClientCallback(eventName: string, cb: (playerId: number, ...args: any[]) => any) {
  onNet(`__ox_cb_${eventName}`, async (resource: string, key: string, ...args: any[]) => {
    const src = source;
    let response: any;

    try {
      response = await cb(src, ...args);
    } catch (e: any) {
      console.error(`an error occurred while handling callback event ${eventName}`);
      console.log(`^3${e.stack}^0`);
    }

    emitNet(`__ox_cb_${resource}`, src, key, response);
  });
}
