interface OxCache {
  ped: number;
  vehicle: number | false;
  seat: number | false;
  game: 'fxserver' | 'fivem' | 'redm';
  resource: string;
  playerId: number;
  serverId: number;
  [key: string]: unknown;
}

const cacheEvents: Record<keyof OxCache, Function[]> = {};

export const cache: OxCache = new Proxy(
  {
    resource: GetCurrentResourceName(),
    game: GetGameName(),
  },
  {
    /** Lazily subscribes to cache updates and reads the initial value from ox_lib. */
    get(target: any, key: string) {
      const result = key ? target[key] : target;
      if (result !== undefined) return result;

      cacheEvents[key] = [];

      AddEventHandler(`ox_lib:cache:${key}`, (value: any) => {
        const oldValue = target[key];
        const events = cacheEvents[key];

        events.forEach((cb) => cb(value, oldValue));

        target[key] = value;
      });

      target[key] = exports.ox_lib.cache(key) ?? false;
      return target[key];
    },
  },
);

/** Subscribes to changes for a cache key, receiving the new and previous values. */
export const onCache = <T extends keyof OxCache>(key: T, cb: (value: OxCache[T], oldValue: OxCache[T]) => void) => {
  if (!cacheEvents[key]) cache[key];

  cacheEvents[key].push(cb);
};
