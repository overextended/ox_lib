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

export interface VehicleProperties {
  model: string;
  plate: string;
  plateIndex: number;
  bodyHealth: number;
  engineHealth: number;
  tankHealth: number;
  fuelLevel: number;
  oilLevel: number;
  dirtLevel: number;
  paintType1: number;
  paintType2: number;
  color1: number | [number, number, number];
  color2: number | [number, number, number];
  pearlescentColor: number;
  interiorColor: number;
  dashboardColor: number;
  wheelColor: number;
  wheelWidth: number;
  wheelSize: number;
  wheels: number;
  windowTint: number;
  xenonColor: number;
  neonEnabled: boolean[];
  neonColor: [number, number, number];
  extras: Record<number | string, 0 | 1>;
  tyreSmokeColor: [number, number, number];
  modSpoilers: number;
  modFrontBumper: number;
  modRearBumper: number;
  modSideSkirt: number;
  modExhaust: number;
  modFrame: number;
  modGrille: number;
  modHood: number;
  modFender: number;
  modRightFender: number;
  modRoof: number;
  modEngine: number;
  modBrakes: number;
  modTransmission: number;
  modHorns: number;
  modSuspension: number;
  modArmor: number;
  modNitrous: number;
  modTurbo: boolean;
  modSubwoofer: boolean;
  modSmokeEnabled: boolean;
  modHydraulics: boolean;
  modXenon: boolean;
  modFrontWheels: number;
  modBackWheels: number;
  modCustomTiresF: boolean;
  modCustomTiresR: boolean;
  modPlateHolder: number;
  modVanityPlate: number;
  modTrimA: number;
  modOrnaments: number;
  modDashboard: number;
  modDial: number;
  modDoorSpeaker: number;
  modSeats: number;
  modSteeringWheel: number;
  modShifterLeavers: number;
  modAPlate: number;
  modSpeakers: number;
  modTrunk: number;
  modHydrolic: number;
  modEngineBlock: number;
  modAirFilter: number;
  modStruts: number;
  modArchCover: number;
  modAerials: number;
  modTrimB: number;
  modTank: number;
  modWindows: number;
  modDoorR: number;
  modLivery: number;
  modRoofLivery: number;
  modLightbar: number;
  windows: number[];
  doors: number[];
  tyres: Record<number | string, 1 | 2>
  leftHeadlight: boolean;
  rightHeadlight: boolean;
  frontBumper: boolean;
  rearBumper: boolean;
  bulletProofTyres: boolean;
  driftTyres: boolean;
}

/**
 * Creates a promise that will be resolved once any value is returned by the function (including null).
 * @param {number?} timeout Error out after `~x` ms. Defaults to 1000, unless set to `false`.
 */
export async function waitFor<T>(cb: () => T, errMessage?: string, timeout?: number | false): Promise<T> {
  let value = await cb();

  if (value !== undefined) return value;

  if (timeout || timeout == null) {
    if (typeof timeout !== 'number') timeout = 1000;

    if (IsDuplicityVersion()) timeout /= 50;
    else timeout -= GetFrameTime() * 1000;
  }

  const start = GetGameTimer();
  let id: number;
  let i = 0;

  const p = new Promise<T>((resolve, reject) => {
    id = setTick(async () => {
      if (timeout) {
        i++;

        if (i > timeout)
          return reject(`${errMessage || 'failed to resolve callback'} (waited ${(GetGameTimer() - start) / 1000}ms)`);
      }

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
