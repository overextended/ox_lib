--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---Load an animation dictionary. When called from a thread, it will yield until it has loaded.
---@param animDict string
---@param timeout number? Approximate milliseconds to wait for the dictionary to load. Default is 10000.
---@return string animDict
function lib.requestAnimDict(animDict, timeout)
    if HasAnimDictLoaded(animDict) then return animDict end

    if type(animDict) ~= 'string' then
        error(("expected animDict to have type 'string' (received %s)"):format(type(animDict)))
    end

    if not DoesAnimDictExist(animDict) then
        error(("attempted to load invalid animDict '%s'"):format(animDict))
    end

    return lib.streamingRequest(RequestAnimDict, HasAnimDictLoaded, 'animDict', animDict, timeout)
end

return lib.requestAnimDict
