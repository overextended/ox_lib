import { cache } from '../../cache';
import { Ped } from '../Ped';

const isServer = cache.game === 'fxserver';

export class Player extends Ped {
  readonly type: string = 'Player';
  readonly playerId;

  constructor(netId: number) {
    if (netId === -1) netId = isServer ? Number(GetPlayerFromIndex(0)) : GetPlayerServerId(PlayerId());

    const playerId = isServer ? netId : GetPlayerFromServerId(netId);

    super(GetPlayerPed(playerId));

    this.playerId = playerId;
  }

  public setModel(model: string | number) {
    SetPlayerModel(this.playerId, model);
  }

  public get handle() {
    return isServer ? super.handle : GetPlayerPed(this.playerId);
  }
}
