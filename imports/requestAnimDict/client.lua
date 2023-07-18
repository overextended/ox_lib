---Load an animation dictionary. When called from a thread, it will yield until it has loaded.
---@param animDict string
---@param timeout number? Number of ticks to wait for the dictionary to load. Default is 500.
---@return string? animDict
function lib.requestAnimDict(animDict, timeout)
    if HasAnimDictLoaded(animDict) then return animDict end

    if type(animDict) ~= 'string' then
        error(("expected animDict to have type 'string' (received %s)"):format(type(animDict)))
    end

    if not DoesAnimDictExist(animDict) then
        return error(("attempted to load invalid animDict '%s'"):format(animDict))
    end

    RequestAnimDict(animDict)

    if coroutine.isyieldable() then
        timeout = tonumber(timeout) or 500

        for _ = 1, timeout do
            if HasAnimDictLoaded(animDict) then
                return animDict
            end

            Wait(0)
        end

        print(("failed to load animDict '%s' after %s ticks"):format(animDict, timeout))
    end

    return animDict
end

return lib.requestAnimDict
