import { GameEntity } from '../Entity';

export class Ped extends GameEntity {
  readonly type: string = 'Ped';

  constructor(handle: number) {
    super();

    this.setHandle(handle);
  }

  public getArmour() {
    return GetPedArmour(this.handle);
  }

  public setArmour(amount: number) {
    SetPedArmour(this.handle, amount);
  }
}
