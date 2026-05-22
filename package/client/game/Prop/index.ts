import { Prop } from '../../../common/game/Prop';
import { requestModel } from '../../streaming';

/**
 * @see {@link CreateObject}
 */
export async function createObject(
  model: string | number,
  x: number,
  y: number,
  z: number,
  heading = 0,
  isNetworked = false,
  netMissionEntity = false,
  dynamic = false
) {
  const hash = await requestModel(model);
  const handle = CreateObject(hash, x, y, z, isNetworked, netMissionEntity, dynamic);
  const prop = new Prop(handle);

  SetModelAsNoLongerNeeded(hash);

  if (heading) prop.setHeading(heading);

  return prop;
}

export { Prop };
