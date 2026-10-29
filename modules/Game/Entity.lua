--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@meta Ox.Game.Entity

local isServer = lib.context == 'server'
local allowStateBagReplication = isServer or not GetConvarBool('sv_stateBagStrictMode', false)

---@class GameEntity : OxClass
---@field handle number The entity's script handle.
---@field netId number The entity's network id.
---@field type string
---@field protected private { handle: number }
---@field package new GameEntityConstructor
local GameEntity = Class('GameEntity')

---@class GameEntityConstructor
---@overload fun(self: GameEntity, handle: number): GameEntity
---@package
function GameEntity:constructor(handle)
    self.private.handle = handle or 0
end

function GameEntity:__index(index)
    if index == 'handle' then
        return self.private.handle
    end

    return GameEntity[index]
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
function GameEntity:set(key, value, mode)
    if mode and self.netId == 0 then mode = nil end

    if (mode == 1 and not allowStateBagReplication) or mode == 2 then
        if mode == 2 and self.type ~= 'Player' then
            error('Setting synced-states is not supported for non-player entities.')
        end

        if not isServer then
            local ok = lib.callback.await('ox_lib:requestSetStateBag', nil, self.statebag, key, value, mode)

            return ok and self:set(key, value) or false
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
function GameEntity:setr(key, value)
    return self:set(key, value, 1)
end

---@async
---@param key string
---@param value unknown
---@return boolean
---Writes a synced value to the entity's state. Client-set values are validated by the server.
function GameEntity:sets(key, value)
    return self:set(key, value, 2)
end

---@param key string
---@return unknown
---Returns a value from the entity's state.
function GameEntity:get(key)
    return GetStateBagValue(self.statebag, key)
end

---@param key string
---@return boolean
---Returns if a key exists in the entity's state.
function GameEntity:has(key)
    return StateBagHasKey(self.statebag, key)
end

---Returns an array of all keys in the entity's state.
function GameEntity:keys()
    return GetStateBagKeys(self.statebag)
end

function GameEntity:setHandle(handle)
    local isPlayer = self.type == 'Player'
    local playerId = isPlayer and self--[[@as Player]].playerId

    self.private.handle = handle
    self.netId = playerId and (isServer and playerId or GetPlayerServerId(playerId)) or NetworkGetNetworkIdFromEntity(handle)
    self.statebag = self.netId == 0 and ('localEntity:%s'):format(handle) or (isPlayer and 'player:%s' or 'entity:%s'):format(self.netId)

    if self.netId == 0 or (isServer and not isPlayer) then
        EnsureEntityStateBag(handle)
    end
end

function GameEntity:getCoords()
    return GetEntityCoords(self.handle)
end

---@param x number
---@param y number
---@param z number
---@param deadFlag? boolean
---@param ragdollFlag? boolean
---@param clearArea? boolean
function GameEntity:setCoords(x, y, z, deadFlag, ragdollFlag, clearArea)
    SetEntityCoords(self.handle, x, y, z, true, deadFlag or false, ragdollFlag or false, clearArea or false)
end

function GameEntity:getModel()
    return GetEntityModel(self.handle)
end

function GameEntity:getHeading()
    return GetEntityHeading(self.handle)
end

---@param heading number
function GameEntity:setHeading(heading)
    SetEntityHeading(self.handle, heading)
end

function GameEntity:getRoutingBucket()
    ---@diagnostic disable-next-line: param-type-mismatch
    return isServer and GetEntityRoutingBucket(self.handle) or self:get('bucket') or 0
end

---@param bucket number
function GameEntity:setRoutingBucket(bucket)
    if not isServer then return end
    ---@diagnostic disable-next-line: param-type-mismatch
    SetEntityRoutingBucket(self.handle, bucket)
    self:set('bucket', bucket, 1)
end

return GameEntity
