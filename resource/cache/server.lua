---@type table<any, {gameTime: number, value: any}>
local ttlCache = {}

---@param key any uniquely identifies a cached value
---@param func function returns the value to cache
---@param maxStalenessMs number values older than maxStaleness are re-computed. Milliseconds
---@return any
function lib.cache.ttl(key, func, maxStalenessMs)
	local gameTime = GetGameTimer()
	if ttlCache[key].gameTime + maxStalenessMs < gameTime then
		ttlCache[key].gameTime = gameTime
		ttlCache[key].value = func()
	end
	return ttlCache[key].value
end
