import { context } from '../..';
import { Ped } from '../Ped';

const isServer = context === 'server';

export class Player extends Ped {
  readonly type: string = 'Player';
  readonly playerId;

  constructor(netId: number) {
    if (netId === -1) netId = isServer ? Number(GetPlayerFromIndex(0)) : GetPlayerServerId(PlayerId());

    const playerId = isServer ? netId : GetPlayerFromServerId(netId);

    super(GetPlayerPed(playerId));

    this.playerId = playerId;
  }

  public get handle() {
    return isServer ? super.handle : GetPlayerPed(this.playerId);
  }

  public setModel(model: string | number) {
    SetPlayerModel(this.playerId, model);
  }

  public getRoutingBucket() {
    return isServer ? GetPlayerRoutingBucket(this.playerId as unknown as string) : (this.get('bucket') ?? 0);
  }

  public setRoutingBucket(bucket: number) {
    if (!isServer) return;

    SetPlayerRoutingBucket(this.playerId as unknown as string, bucket);
    this.set('bucket', bucket, true);
  }
}
