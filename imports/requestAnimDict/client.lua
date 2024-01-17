---Load an animation dictionary. When called from a thread, it will yield until it has loaded.
---@param animDict string
---@param timeout number? Approximate milliseconds to wait for the dictionary to load. Default is 1000.
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

    if not coroutine.isyieldable() then return animDict end

    return lib.waitFor(function()
        if HasAnimDictLoaded(animDict) then return animDict end
    end, ("failed to load animDict '%s'"):format(animDict), timeout)
end

return lib.requestAnimDict
