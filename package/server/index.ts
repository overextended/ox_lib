import { VehicleProperties } from '../common';

export * from '../common';
export * from './acl';
export * from './addCommand';
export * from './cache';
export * from './callback';
export * from './locale';
export * from './version';
export * as lib from '.';

export function setVehicleProperties(vehicle: number, props: VehicleProperties) {
  Entity(vehicle).state.set('ox_lib:setVehicleProperties', props, true)
}
