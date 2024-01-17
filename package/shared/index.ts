export * from './resource';

// https://www.raygesualdo.com/posts/flattening-object-keys-with-typescript-types/
export type FlattenObjectKeys<T extends Record<string, unknown>, Key = keyof T> = Key extends string
  ? T[Key] extends Record<string, unknown>
    ? `${Key}.${FlattenObjectKeys<T[Key]>}`
    : `${Key}`
  : never;

export function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms, null));
}

export async function waitFor<T>(cb: () => T, errMessage: string | void, timeout = 1000): Promise<T> {
  let value = await cb();

  if (value !== undefined) return value;

  if (IsDuplicityVersion()) timeout /= 50;
  else timeout -= GetFrameTime() * 1000;

  const start = GetGameTimer();
  let id: number;
  let i = 0;

  const p = new Promise<T>((resolve, reject) => {
    id = setTick(async () => {
      i++;

      if (i > timeout)
        return reject(`${errMessage || 'failed to resolve callback'} (waited ${(GetGameTimer() - start) / 1000}ms)`);

      value = await cb();

      if (value !== undefined) resolve(value);
    });
  }).finally(() => clearTick(id));

  return p;
}
