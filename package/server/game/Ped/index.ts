import { Ped } from '../../../common/game/Ped';

/**
 * @see {@link CreatePed}
 */
export async function createPed(model: string | number, x: number, y: number, z: number, heading = 0) {
  const handle = CreatePed(0, model, x, y, z, heading, true, true);

  return new Ped(handle);
}

export { Ped };
