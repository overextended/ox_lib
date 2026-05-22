--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local isServer = lib.context == 'server'

---@class Player : Ped
---@field private new PlayerConstructor
lib.player = lib.class('Player', lib.ped)

---@class PlayerConstructor
---@overload fun(self: Player, netId: number): Player
function lib.player:constructor(netId)
    if netId == -1 then netId = isServer and tonumber(GetPlayerFromIndex(0)) or cache.playerId end

    local playerId = isServer and netId or GetPlayerFromServerId(netId)

    self:super(GetPlayerPed(playerId))
    self.playerId = playerId
end

function lib.player:__index(index)
    if index == 'handle' then
        return isServer and self.private.handle or GetPlayerPed(self.playerId)
    end

    return lib.player[index]
end

---@param model string | number
function lib.player:setModel(model)
    SetPlayerModel(self.playerId, model)
end

function lib.player:getRoutingBucket()
    ---@diagnostic disable-next-line: param-type-mismatch
    return isServer and GetPlayerRoutingBucket(self.playerId) or self:get('bucket') or 0
end

---@param bucket number
function lib.player:setRoutingBucket(bucket)
    if not isServer then return end

    ---@diagnostic disable-next-line: param-type-mismatch
    SetPlayerRoutingBucket(self.playerId, bucket)
    self:set('bucket', bucket, true)
end

return lib.player

