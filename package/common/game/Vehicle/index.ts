import { context } from '../..';
import { GameEntity } from '../Entity';

export type VehicleType = 'automobile' | 'bike' | 'boat' | 'heli' | 'plane' | 'submarine' | 'trailer' | 'train';

export class Vehicle extends GameEntity {
  /** Wraps an existing vehicle handle and its state bag. */
  constructor(handle: number) {
    super();

    this.setHandle(handle);
  }

  /** Returns the vehicle's category used by server vehicle creation. */
  public getType() {
    return GetVehicleType(this.handle) as VehicleType;
  }

  /** Returns the vehicle's number plate text. */
  public getPlate() {
    return GetVehicleNumberPlateText(this.handle);
  }

  /** Sets the vehicle's number plate text. */
  public setPlate(plate: string) {
    SetVehicleNumberPlateText(this.handle, plate);
  }

  /** Places the vehicle on the ground locally or requests placement through replicated state. */
  public setOnGround() {
    if (context === 'client') return SetVehicleOnGroundProperly(this.handle);

    return this.setr('ox_entity_setonground', true);
  }
}
