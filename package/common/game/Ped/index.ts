import { GameEntity } from '../Entity';

export class Ped extends GameEntity {
  readonly type: string = 'Ped';

  /** Wraps an existing ped handle, or leaves the wrapper unbound for a zero handle. */
  constructor(handle: number) {
    super();

    if (!handle) return;

    this.setHandle(handle);
  }

  /** Returns the ped's current armour amount. */
  public getArmour() {
    return GetPedArmour(this.handle);
  }

  /** Sets the ped's armour amount. */
  public setArmour(amount: number) {
    SetPedArmour(this.handle, amount);
  }
}
