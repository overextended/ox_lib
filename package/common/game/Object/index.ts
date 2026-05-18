import { GameEntity } from '../Entity';

export class Object extends GameEntity {
  constructor(handle: number) {
    super();

    this.setHandle(handle);
  }
}
