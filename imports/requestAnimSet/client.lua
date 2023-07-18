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

    if coroutine.isyieldable() then
        timeout = tonumber(timeout) or 500

        for _ = 1, timeout do
            if HasAnimSetLoaded(animSet) then
                return animSet
            end

            Wait(0)
        end

        print(("failed to load animSet '%s' after %s ticks"):format(animSet, timeout))
    end

    return animSet
end

return lib.requestAnimSet
