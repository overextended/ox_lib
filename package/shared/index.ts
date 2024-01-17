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

export function getRandomInt(min = 0, max = 9) {
  if (min > max) [min, max] = [max, min];

  return Math.floor(Math.random() * (max - min + 1)) + min;
}

export function getRandomChar(lowercase?: boolean) {
  const str = String.fromCharCode(getRandomInt(65, 90));
  return lowercase ? str.toLowerCase() : str;
}

export function getRandomAlphanumeric(lowercase?: boolean) {
  return Math.random() > 0.5 ? getRandomChar(lowercase) : getRandomInt();
}

const formatChar: Record<string, (...args: any) => string | number> = {
  '1': getRandomInt,
  A: getRandomChar,
  '.': getRandomAlphanumeric,
  a: getRandomChar,
};

export function getRandomString(pattern: string, length?: number): string {
  const len = length || pattern.replace(/\^/g, '').length;
  const arr: Array<string | number> = Array(len).fill(0);
  let size = 0;
  let i = 0;

  while (size < len) {
    i += 1;
    let char: string | number = pattern.charAt(i - 1);

    if (char === '') {
      arr[size] = ' '.repeat(len - size);
      break;
    } else if (char === '^') {
      i += 1;
      char = pattern.charAt(i - 1);
    } else {
      const fn = formatChar[char];
      char = fn ? fn(char === 'a') : char;
    }

    size += 1;
    arr[size - 1] = char;
  }

  return arr.join('');
}
