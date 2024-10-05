import { cache } from '../cache';

const pendingCallbacks: Record<string, (...args: any[]) => void> = {};
const callbackTimeout = GetConvarInt('ox:callbackTimeout', 300000);

onNet(`__ox_cb_${cache.resource}`, (key: string, ...args: any) => {
  const resolve = pendingCallbacks[key];
  delete pendingCallbacks[key];

  return resolve && resolve(...args);
});

const eventTimers: Record<string, number> = {};

export function eventTimer(eventName: string, delay: number | null) {
  if (delay && delay > 0) {
    const currentTime = GetGameTimer();

    if ((eventTimers[eventName] || 0) > currentTime) return false;

    eventTimers[eventName] = currentTime + delay;
  }

  return true;
}

export function triggerServerCallback<T = unknown>(
  eventName: string,
  delay: number | null,
  ...args: any
): Promise<T> | void {
  if (!eventTimer(eventName, delay)) return;

  let key: string;

  do {
    key = `${eventName}:${Math.floor(Math.random() * (100000 + 1))}`;
  } while (pendingCallbacks[key]);

  emitNet(`__ox_cb_${eventName}`, cache.resource, key, ...args);

  return new Promise<T>((resolve, reject) => {
    pendingCallbacks[key] = resolve;

    setTimeout(reject, callbackTimeout, `callback event '${key}' timed out`);
  });
}

export function onServerCallback(eventName: string, cb: (...args: any[]) => any) {
  onNet(`__ox_cb_${eventName}`, async (resource: string, key: string, ...args: any[]) => {
    let response: any;

    try {
      response = await cb(...args);
    } catch (e: any) {
      console.error(`an error occurred while handling callback event ${eventName}`);
      console.log(`^3${e.stack}^0`);
    }

    emitNet(`__ox_cb_${resource}`, key, response);
  });
}
