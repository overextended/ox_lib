import * as lib from './resource';
import { cache, onCache } from '../shared/resource';

cache.playerId = PlayerId();
cache.serverId = GetPlayerServerId(cache.playerId);

export { cache, onCache };
export * from './resource';
export default lib;
