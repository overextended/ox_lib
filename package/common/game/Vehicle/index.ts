import { GameEntity } from '../Entity';

type VehicleType = 'automobile' | 'bike' | 'boat' | 'heli' | 'plane' | 'submarine' | 'trailer' | 'train';

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
}
