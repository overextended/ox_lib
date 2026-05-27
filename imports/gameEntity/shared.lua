--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local isServer = lib.context == 'server'
local allowStateBagReplication = isServer or not GetConvarBool('sv_stateBagStrictMode', false)

---@class GameEntity : OxClass
---@field handle number
---@field netId number
---@field protected private { handle: number }
---@field package new GameEntityConstructor
lib.gameEntity = lib.class('GameEntity')

---@class GameEntityConstructor
---@overload fun(self: GameEntity, handle: number): GameEntity
---@package
function lib.gameEntity:constructor(handle)
    self.private.handle = handle or 0
end

function lib.gameEntity:__index(index)
    if index == 'handle' then
        return self.private.handle
    end

    return lib.gameEntity[index]
end

---@alias StateBagReplication
---|1 The value is replicated to the server and all relevant clients.
---|2 The value is synced between the server and entity owner. Player only.

---@async
---@param key string
---@param value unknown
---@param mode? StateBagReplication
---@return boolean
---Writes a value to the entity's state. Replicated values are validated by the server.
function lib.gameEntity:set(key, value, mode)
    if (mode == 1 and not allowStateBagReplication) or mode == 2 then
        if mode == 2 and not self:instanceOf(lib.player) then
            error('Setting synced-states is not supported for non-player entities.')
        end

        if not isServer then
            return lib.callback.await('ox_lib:requestSetStateBag', nil, self.statebag, key, value, mode)
        end

        TriggerClientEvent('ox_lib:setStateBagValue', self.netId, key, value)
    end

    local packed = msgpack.pack(value)
    SetStateBagValue(self.statebag, key, packed, #packed, mode == 1)

    return true
end

---@async
---@param key string
---@param value unknown
---@return boolean
---Writes a replicated value to the entity's state. Client-set values are validated by the server.
function lib.gameEntity:setr(key, value)
    return self:set(key, value, 1)
end

---@async
---@param key string
---@param value unknown
---@return boolean
---Writes a synced value to the entity's state. Client-set values are validated by the server.
function lib.gameEntity:sets(key, value)
    return self:set(key, value, 2)
end

---@param key string
---@return unknown
---Returns a value from the entity's state.
function lib.gameEntity:get(key)
    return GetStateBagValue(self.statebag, key)
end

---@param key string
---@return boolean
---Returns if a key exists in the entity's state.
function lib.gameEntity:has(key)
    return StateBagHasKey(self.statebag, key)
end

---Returns an array of all keys in the entity's state.
function lib.gameEntity:keys()
    return GetStateBagKeys(self.statebag)
end

function lib.gameEntity:setHandle(handle)
    local isPlayer = self:instanceOf(lib.player)
    self.private.handle = handle
    self.netId = NetworkGetNetworkIdFromEntity(handle)
    self.statebag = self.netId == 0 and ('localEntity:%s'):format(handle) or isPlayer and ('player:%s' or 'entity:%s'):format(self.netId)

    if self.netId == 0 or (isServer and not isPlayer) then
        EnsureEntityStateBag(handle)
    end
end

function lib.gameEntity:getCoords()
    return GetEntityCoords(self.handle)
end

---@param x number
---@param y number
---@param z number
---@param deadFlag? boolean
---@param ragdollFlag? boolean
---@param clearArea? boolean
function lib.gameEntity:setCoords(x, y, z, deadFlag, ragdollFlag, clearArea)
    SetEntityCoords(self.handle, x, y, z, true, deadFlag or false, ragdollFlag or false, clearArea or false)
end

function lib.gameEntity:getModel()
    return GetEntityModel(self.handle)
end

function lib.gameEntity:getHeading()
    return GetEntityHeading(self.handle)
end

---@param heading number
function lib.gameEntity:setHeading(heading)
    SetEntityHeading(self.handle, heading)
end

function lib.gameEntity:getRoutingBucket()
    ---@diagnostic disable-next-line: param-type-mismatch
    return isServer and GetEntityRoutingBucket(self.handle) or self:get('bucket') or 0
end

---@param bucket number
function lib.gameEntity:setRoutingBucket(bucket)
    if not isServer then return end
    ---@diagnostic disable-next-line: param-type-mismatch
    SetEntityRoutingBucket(self.handle, bucket)
    self:set('bucket', bucket, 1)
end

return lib.gameEntity
