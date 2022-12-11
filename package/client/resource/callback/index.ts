import { cache } from '../cache';

const activeEvents: Record<string, Function> = {};

onNet(`__ox_cb_${cache.resource}`, (key: string, ...args: any) => {
  const resolve = activeEvents[key];
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

export function triggerServerCallback(eventName: string, delay: number | null, ...args: any) {
  if (!eventTimer(eventName, delay)) return;

  let key: string;

  do {
    key = `${eventName}:${Math.floor(Math.random() * (100000 + 1))}`;
  } while (activeEvents[key]);

  emitNet(`__ox_cb_${eventName}`, cache.resource, key, ...args);

  return new Promise((resolve) => {
    activeEvents[key] = resolve;
  });
}

export function onServerCallback(eventName: string, cb: (...args: any) => any) {
  onNet(`__ox_cb_${eventName}`, (resource: string, key: string, ...args: any) => {
    let response: any;

    try {
      response = cb(...args);
    } catch (e: any) {
      console.error(`an error occurred while handling callback event ${eventName}`);
      console.log(`^3${e.stack}^0`);
    }

    emitNet(`__ox_cb_${resource}`, key, response);
  });
}
