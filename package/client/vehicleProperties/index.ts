import type { VehicleProperties } from '..';

/** Reads the vehicle appearance, modifications, damage, and fluid properties. */
export const getVehicleProperties = (vehicle: number): VehicleProperties =>
  exports.ox_lib.getVehicleProperties(vehicle);

/** Applies supplied vehicle properties, optionally repairing the vehicle afterward. */
export const setVehicleProperties = (
  vehicle: number,
  props: Partial<VehicleProperties>,
  fixVehicle?: boolean,
): boolean => exports.ox_lib.setVehicleProperties(vehicle, props, fixVehicle);
