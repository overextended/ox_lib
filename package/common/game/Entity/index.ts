import { Vector3 } from '@overextended/core/vector';
import { cache } from '../../cache';
import { StateBag } from '../StateBag';

export abstract class GameEntity extends StateBag {
  #handle: number = 0;
  readonly type: string = '';
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

  public setCoords(x: number, y: number, z: number, deadFlag = false, ragdollFlag = false, clearArea = false) {
    SetEntityCoords(this.handle, x, y, z, true, deadFlag, ragdollFlag, clearArea);
  }

  public getModel() {
    return GetEntityModel(this.handle);
  }

  public getHeading() {
    return GetEntityHeading(this.handle);
  }

  public setHeading(heading: number) {
    SetEntityHeading(this.handle, heading);
  }
}
