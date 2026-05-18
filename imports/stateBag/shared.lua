--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local allowStateBagReplication = cache.game == 'fxserver' or not GetConvarBool('sv_stateBagStrictMode', false)

---@class OxStateBag : OxClass
---@field protected statebag string
---@field private new StateBagConstructor
lib.stateBag = lib.class('OxStateBag')

---@class StateBagConstructor
---@overload fun(self: StateBag, statebag: string): StateBag
---@private
function lib.stateBag:constructor(statebag)
    self.statebag = statebag
end

---@async
---@param key string
---@param value unknown
---@param replicated? boolean
---@return boolean
---Writes a value to the statebag. Replicated values set from the client are send to the server for validation.
function lib.stateBag:set(key, value, replicated)
    if replicated and not allowStateBagReplication then
        return lib.callback.await('ox_lib:requestSetStateBag', nil, self.statebag, key, value)
    end

    local packed = msgpack.pack(value)
    SetStateBagValue(self.statebag, key, packed, #packed, replicated or false)

    return true
end

---@param key string
---@return unknown
---Returns a value from the statebag.
function lib.stateBag:get(key)
    return GetStateBagValue(self.statebag, key)
end

---@param key string
---@return boolean
---Returns if a key exists on the statebag.
function lib.stateBag:has(key)
    return StateBagHasKey(self.statebag, key)
end

---Returns an array of all keys on the statebag.
function lib.stateBag:keys()
    return GetStateBagKeys(self.statebag)
end

return lib.stateBag
