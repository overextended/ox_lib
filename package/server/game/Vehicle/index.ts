import { Vehicle, type VehicleType } from "../../../common/game/Vehicle";

/** Creates a server vehicle using the setter native or the RedM creation fallback. */
const CreateVehicleServerSetter =
  globalThis.CreateVehicleServerSetter ||
  ((model: string | number, type: VehicleType, x: number, y: number, z: number, heading = 0) => {
    return CreateVehicle(model, x, y, z, heading, true, true);
  });

/**
 * Creates a networked vehicle on the server and returns its wrapper.
 * @see {@link CreateVehicleServerSetter} (FiveM)
 * @see {@link CreateVehicle} (RedM)
 */
export async function createVehicle(
  model: string | number,
  type: VehicleType,
  x: number,
  y: number,
  z: number,
  heading = 0,
) {
  const handle = CreateVehicleServerSetter(model, type, x, y, z, heading);

  return new Vehicle(handle);
}

export { Vehicle };
