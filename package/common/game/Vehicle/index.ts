import { context } from '../..';
import { GameEntity } from '../Entity';

export type VehicleType = 'automobile' | 'bike' | 'boat' | 'heli' | 'plane' | 'submarine' | 'trailer' | 'train';

export class Vehicle extends GameEntity {
  constructor(handle: number) {
    super();

    this.setHandle(handle);
  }

  public getType() {
    return GetVehicleType(this.handle) as VehicleType;
  }

  public getPlate() {
    return GetVehicleNumberPlateText(this.handle);
  }

  public setPlate(plate: string) {
    SetVehicleNumberPlateText(this.handle, plate);
  }

  public setOnGround() {
    if (context === 'client') return SetVehicleOnGroundProperly(this.handle);

    return this.setr('ox_entity_setonground', true);
  }
}
