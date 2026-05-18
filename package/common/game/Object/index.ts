import { GameEntity } from '../Entity';

export class Object extends GameEntity {
  readonly type: string = 'Object';

  constructor(handle: number) {
    super();

    this.setHandle(handle);
  }
}
