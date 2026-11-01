import { context } from '../..';
import { Ped } from '../Ped';

const isServer = context === 'server';
const players = new Map<number, WeakRef<Player>>();
const registry = new FinalizationRegistry((id: number) => players.delete(id));

type StateChangeHandler<T = any> = (player: Player, key: string, value?: T, old?: T) => void

const stateChangeHandlers = new Map<string, {
  cb: StateChangeHandler;
  cookie: number;
}[]>();

function getPlayer(id: number) {
  let player = players.get(id)?.deref();

  if (!player) {
    player = new Player(id);
    const ref = new WeakRef(player);

    players.set(id, ref);
    registry.register(player, id, ref)
  }

  return player;
}

function triggerStateChangeHandlers(bag: string, key: string, value: unknown) {
  if (!bag.startsWith('player:')) return;

  const playerId = GetPlayerFromStateBagName(bag);
  const handlers = playerId && stateChangeHandlers.get(key);

  if (!handlers) return;

  const player = getPlayer(playerId);

  for (const handler of handlers) {
    handler.cb(player, key, value, GetStateBagValue(bag, key));
  }
}

export class Player extends Ped {
  readonly type: string = 'Player';
  readonly playerId;
  /** The player's server id. */
  readonly netId: number = 0;

  static on<T = unknown>(key: string, handler: StateChangeHandler<T>) {
    let handlers = stateChangeHandlers.get(key);

    if (!handlers) {
      handlers = [];
      stateChangeHandlers.set(key, handlers);
    }

    handlers.push({
      cb: handler,
      cookie: AddStateBagChangeHandler(key, '', triggerStateChangeHandlers),
    });
  }

  constructor(netId: number) {
    if (netId === -1) netId = isServer ? Number(GetPlayerFromIndex(0)) : GetPlayerServerId(PlayerId());

    const playerId = isServer ? netId : GetPlayerFromServerId(netId);

    super(0);
    this.playerId = playerId;
    this.setHandle(GetPlayerPed(playerId));
  }

  /** The player ped's script handle. */
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
    this.set('bucket', bucket, 1);
  }
}
