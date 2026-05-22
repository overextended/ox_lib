import { Prop } from '../../../common/game/Prop';

/**
 * @see {@link CreateObjectNoOffset}
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
  const handle = CreateObjectNoOffset(model, x, y, z, isNetworked, netMissionEntity, dynamic);
  const prop = new Prop(handle);

  if (heading) prop.setHeading(heading);

  return prop;
}

export { Prop };
