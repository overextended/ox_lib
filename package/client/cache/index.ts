import { cache, onCache } from '../../common';

cache.playerId = PlayerId();
cache.serverId = GetPlayerServerId(cache.playerId);

export { cache, onCache };
