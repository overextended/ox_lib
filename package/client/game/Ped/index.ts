import { Ped } from '../../../common/game/Ped';
import { requestModel } from '../../streaming';

/**
 * @see {@link CreatePed}
 */
export async function createPed(
  model: string | number,
  x: number,
  y: number,
  z: number,
  heading = 0,
  isNetworked = false,
  bScriptHostPed = false,
) {
  const hash = await requestModel(model);
  const handle = CreatePed(0, hash, x, y, z, heading, isNetworked, bScriptHostPed);

  SetModelAsNoLongerNeeded(hash);

  return new Ped(handle);
}

export { Ped };
