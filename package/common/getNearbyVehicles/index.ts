import { cache } from '../cache/index';
import { context } from '../';
import { Vector3 } from '@overextended/core/vector';

interface NearbyVehicle {
  vehicle: number;
  coords: Vector3;
}

export function getNearbyVehicles(
  coords: Vector3,
  maxDistance: number = 2.0,
  includePlayerVehicle: boolean = false,
): NearbyVehicle[] {
  const vehicles = GetGamePool('CVehicle');
  const nearbyVehicles: NearbyVehicle[] = [];

  for (const vehicle of vehicles) {
    if (context === 'server' || !cache.vehicle || vehicle !== cache.vehicle || includePlayerVehicle) {
      const vehicleCoords = Vector3.fromArray(GetEntityCoords(vehicle, true));
      const distance = vehicleCoords.distance(coords);

      if (distance < maxDistance && NetworkGetEntityIsNetworked(vehicle)) {
        nearbyVehicles.push({
          vehicle,
          coords: vehicleCoords,
        });
      }
    }
  }

  return nearbyVehicles;
}
