import { context } from '../..';
import { Ped } from '../Ped';

const isServer = context === 'server';
const players = new Map<number, WeakRef<Player>>();
const registry = new FinalizationRegistry((id: number) => players.delete(id));

type StateChangeHandler<T = any> = (player: Player, key: string, value?: T, old?: T) => void;

const stateChangeHandlers = new Map<string, {
  cookie: number;
  subscriptions: Set<{ cb: StateChangeHandler }>;
}>();

/** Returns the cached player wrapper or creates one for the supplied id. */
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

/** Dispatches player state changes with the new value and the previous bag value. */
function triggerStateChangeHandlers(bag: string, key: string, value: unknown) {
  if (!bag.startsWith('player:')) return;

  const playerId = GetPlayerFromStateBagName(bag);

  if (isServer ? playerId <= 0 : playerId < 0) return;

  const serverId = isServer ? playerId : GetPlayerServerId(playerId);

  if (serverId <= 0 || bag !== `player:${serverId}`) return;

  const handlers = stateChangeHandlers.get(key);

  if (!handlers) return;

  const player = getPlayer(serverId);
  const old = GetStateBagValue(bag, key);
  const subscriptions = [...handlers.subscriptions];

  for (const subscription of subscriptions) {
    if (handlers.subscriptions.has(subscription)) subscription.cb(player, key, value, old);
  }
}

export class Player extends Ped {
  readonly type: string = 'Player';
  readonly playerId;
  /** The player's server id. */
  readonly netId: number = 0;

  /** Registers a player state callback and returns a function that unsubscribes it. */
  static on<T = unknown>(key: string, handler: StateChangeHandler<T>): () => void {
    let handlers = stateChangeHandlers.get(key);

    if (!handlers) {
      handlers = {
        cookie: AddStateBagChangeHandler(key, '', triggerStateChangeHandlers),
        subscriptions: new Set(),
      };
      stateChangeHandlers.set(key, handlers);
    }

    const subscription = { cb: handler };
    handlers.subscriptions.add(subscription);

    return () => {
      if (!handlers.subscriptions.delete(subscription) || handlers.subscriptions.size) return;

      RemoveStateBagChangeHandler(handlers.cookie);
      stateChangeHandlers.delete(key);
    };
  }

  /** Wraps a player server id, using the local client or first server player for -1. */
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

  /** Changes the player's ped model. */
  public setModel(model: string | number) {
    SetPlayerModel(this.playerId, model);
  }

  /** Returns the player's server routing bucket or its client state bag value. */
  public getRoutingBucket() {
    return isServer ? GetPlayerRoutingBucket(this.playerId as unknown as string) : (this.get('bucket') ?? 0);
  }

  /** Sets and replicates the player's routing bucket on the server. */
  public setRoutingBucket(bucket: number) {
    if (!isServer) return;

    SetPlayerRoutingBucket(this.playerId as unknown as string, bucket);
    this.set('bucket', bucket, 1);
  }
}
