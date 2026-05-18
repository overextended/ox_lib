import { Vector3 } from '@overextended/core/vector';
import { cache } from '../../cache';
import { StateBag } from '../StateBag';

export abstract class GameEntity extends StateBag {
  #handle: number = 0;
  protected type = this.constructor.name;
  readonly netId: number = 0;

  public get handle() {
    return this.#handle;
  }

  protected setHandle(handle: number) {
    this.#handle = handle;
    // @ts-ignore
    this.netId = NetworkGetNetworkIdFromEntity(handle);

    this.statebag = this.netId
      ? `${this.type === 'Player' ? 'player' : 'entity'}:${this.netId}`
      : `localEntity:${handle}`;

    if ((!this.netId || cache.game === 'fxserver') && this.type !== 'Player') {
      EnsureEntityStateBag(handle);
    }
  }

  public getCoords() {
    return Vector3.fromArray(GetEntityCoords(this.handle));
  }

  public getModel() {
    return GetEntityModel(this.handle);
  }
}
