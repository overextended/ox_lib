import { VehicleProperties } from "../common";

export function setVehicleProperties(vehicle: number, props: VehicleProperties) {
    Entity(vehicle).state.set('ox_lib:setVehicleProperties', props, true);
}
