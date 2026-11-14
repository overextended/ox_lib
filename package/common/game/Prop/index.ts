import { context } from '../..';
import { GameEntity } from '../Entity';

export class Prop extends GameEntity {
  readonly type: string = 'Prop';

  /** Wraps an existing object handle and its state bag. */
  constructor(handle: number) {
    super();

    this.setHandle(handle);
  }

  /** Places the object on the ground locally or requests placement through replicated state. */
  public setOnGround() {
    if (context === 'client') return PlaceObjectOnGroundProperly(this.handle);

    return this.setr('ox_entity_setonground', true);
  }
}
