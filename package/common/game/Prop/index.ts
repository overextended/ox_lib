import { context } from '../..';
import { GameEntity } from '../Entity';

export class Prop extends GameEntity {
  readonly type: string = 'Prop';

  constructor(handle: number) {
    super();

    this.setHandle(handle);
  }

  public setOnGround() {
    if (context === 'client') return PlaceObjectOnGroundProperly(this.handle);

    return this.setr('ox_entity_setonground', true);
  }
}
