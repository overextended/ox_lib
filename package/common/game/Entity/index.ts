import { Vector3 } from '@overextended/core/vector';
import { context } from '../..';

const isServer = context === 'server';
const allowStateBagReplication = isServer || !GetConvarBool('sv_stateBagStrictMode', false);

enum StateBagReplication {
  /** The value is replicated to the server and all relevant clients. */
  REPLICATED = 1,
  /** The value is synced between the server and entity owner. Player only. */
  SYNCED = 2,
}

export abstract class GameEntity {
  #handle: number = 0;
  readonly type: string = '';
  /** The entity's network id. */
  readonly netId: number = 0;
  protected statebag: string = '';

  /** Writes a value to the entity's state. Replicated values are validated by the server. */
  public async set(key: string, value: unknown, mode?: StateBagReplication): Promise<boolean> {
    if (mode && !this.netId) mode = undefined;
  
    if ((mode === 1 && !allowStateBagReplication) || mode === 2) {
      if (mode === 2 && this.type !== 'Player') {
        throw new Error('Setting synced-states is not supported for non-player entities.');
      }

      if (!isServer) {
        const ok = await import('../../../client/callback').then(
          (m) =>
            m.triggerServerCallback('ox_lib:requestSetStateBag', null, this.statebag, key, value) as Promise<boolean>,
        );

        return ok ? this.set(key, value) : false;
      }

      emitNet('ox_lib:setStateBagValue', this.netId, key, value);
    }

    // @ts-ignore
    const packed = msgpack_pack(value);
    SetStateBagValue(this.statebag, key, packed, packed.length, mode === 1);

    return true;
  }

  /** Writes a replicated value to the entity's state. Client-set values are validated by the server. */
  public async setr(key: string, value: unknown) {
    return this.set(key, value, 1);
  }

  /** Writes a synced value to the entity's state. Client-set values are validated by the server. */
  public async sets(key: string, value: unknown) {
    return this.set(key, value, 2);
  }

  /** Returns a value from the entity's state. */
  public get<T = unknown>(key: string): T | undefined {
    return GetStateBagValue(this.statebag, key);
  }

  /** Returns if a key exists in the entity's state. */
  public has(key: string) {
    return !!StateBagHasKey(this.statebag, key);
  }

  /** Returns an array of all keys in the entity's state. */
  public keys(): string[] {
    return GetStateBagKeys(this.statebag);
  }

  /** The entity's script handle */
  public get handle() {
    return this.#handle;
  }

  protected setHandle(handle: number) {
    const isPlayer = this.type === 'Player';
    const playerId = isPlayer && ((this as any).playerId as number);
    this.#handle = handle;
    // @ts-expect-error
    this.netId = playerId ? (isServer ? playerId : GetPlayerServerId(playerId)) : NetworkGetNetworkIdFromEntity(handle);
    this.statebag = this.netId ? `${isPlayer ? 'player' : 'entity'}:${this.netId}` : `localEntity:${handle}`;

    if (!this.netId || (isServer && !isPlayer)) {
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

  public getRoutingBucket() {
    return isServer ? GetEntityRoutingBucket(this.handle) : (this.get('bucket') ?? 0);
  }

  public setRoutingBucket(bucket: number) {
    if (!isServer) return;

    SetEntityRoutingBucket(this.handle, bucket);
    this.set('bucket', bucket, 1);
  }
}
