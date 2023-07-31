---Load an animation clipset. When called from a thread, it will yield until it has loaded.
---@param animSet string
---@param timeout number? Number of ticks to wait for the clipset to load. Default is 500.
---@return string? animSet
function lib.requestAnimSet(animSet, timeout)
    if HasAnimSetLoaded(animSet) then return animSet end

    if type(animSet) ~= 'string' then
        error(("expected animSet to have type 'string' (received %s)"):format(type(animSet)))
    end

    RequestAnimSet(animSet)

    if not coroutine.isyieldable() then return animSet end

    return lib.waitFor(function()
        if HasAnimSetLoaded(animSet) then return animSet end
    end, ("failed to load animSet '%s'"):format(animSet), timeout or 500)
end

return lib.requestAnimSet
