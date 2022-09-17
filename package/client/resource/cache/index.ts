import { cache, onCache } from '../../../shared';

cache.playerId = PlayerId();
cache.serverId = GetPlayerServerId(cache.playerId);

export { cache, onCache };
