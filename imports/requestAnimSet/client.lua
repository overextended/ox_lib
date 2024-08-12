---Load an animation clipset. When called from a thread, it will yield until it has loaded.
---@param animSet string
---@param timeout number? Approximate milliseconds to wait for the clipset to load. Default is 10000.
---@return string animSet
function lib.requestAnimSet(animSet, timeout)
    if HasAnimSetLoaded(animSet) then return animSet end

    if type(animSet) ~= 'string' then
        error(("expected animSet to have type 'string' (received %s)"):format(type(animSet)))
    end

    return lib.streamingRequest(RequestAnimSet, HasAnimSetLoaded, 'animSet', animSet, timeout)
end

return lib.requestAnimSet
