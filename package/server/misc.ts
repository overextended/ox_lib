import type { VehicleProperties } from "../common";

/** Replicates vehicle properties for the owning client to apply. */
export function setVehicleProperties(vehicle: number, props: VehicleProperties) {
  Entity(vehicle).state.set('ox_lib:setVehicleProperties', props, true);
}
