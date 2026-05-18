import { cache } from '../../cache';

const allowStateBagReplication = cache.game === 'fxserver' || !GetConvarBool('sv_stateBagStrictMode', false);

export class StateBag {
  protected statebag;

  constructor(statebag: string = '') {
    this.statebag = statebag;
  }

  /** Writes a value to the statebag. */
  public async set(key: string, value: unknown, replicated = false) {
    if (replicated && !allowStateBagReplication) {
      return import('../../../client/callback').then(
        (m) => m.triggerServerCallback('ox_lib:requestSetStateBag', null, this.statebag, key, value) as Promise<boolean>
      );
    }

    // @ts-ignore
    const packed = msgpack_pack(value);
    SetStateBagValue(this.statebag, key, packed, packed.length, replicated);

    return true;
  }

  /** Returns a value from the statebag. */
  public get(key: string) {
    return GetStateBagValue(this.statebag, key);
  }

  /** Returns if a key exists on the statebag. */
  public has(key: string) {
    return !!StateBagHasKey(this.statebag, key);
  }

  /** Returns an array of all keys on the statebag. */
  public keys(): string[] {
    return GetStateBagKeys(this.statebag);
  }
}

export const GlobalState = new StateBag('global');