import { Vehicle } from '../../../common/game/Vehicle';
import { requestModel } from '../../streaming';

/**
 * @see {@link CreateVehicle}
 */
export async function createVehicle(
  model: string | number,
  x: number,
  y: number,
  z: number,
  heading = 0,
  isNetworked = false,
  netMissionEntity = false,
) {
  const hash = await requestModel(model);
  const handle = CreateVehicle(hash, x, y, z, heading, isNetworked, netMissionEntity);
  const vehicle = new Vehicle(handle);

  SetModelAsNoLongerNeeded(hash);

  return vehicle;
}

export { Vehicle };
