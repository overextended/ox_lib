--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@meta Ox.Game.Player

local Ped = require 'Ox.Game.Ped'
local isServer = lib.context == 'server'

---@class Player : Ped
---@field handle number The player ped's script handle.
---@field netId number The player's server id.
---@field new PlayerConstructor
---@field create nil
local Player = Class('Player', Ped)
Player.type = Player.__name

local players = setmetatable({}, {
    __mode = 'v',
    __index = function(self, key)
        self[key] = Player:new(key)
        return self[key]
    end
})

local stateChangeHandlers = {}

local function triggerStateChangeHandlers(bag, key, value)
    if not bag:find('^player:') then return end

    local playerId = GetPlayerFromStateBagName(bag)
    local handlers = playerId ~= 0 and stateChangeHandlers[key]

    if not handlers then return end

    local player = players[playerId]

    for i = 1, #handlers do
        local handler = handlers[i]
        handler.cb(player, key, value, GetStateBagValue(bag, key))
    end
end

---@param key string
---@param handler fun(player: Player, key: string, value?: unknown, old?: unknown)
function Player.on(key, handler)
    local handlers = stateChangeHandlers[key]

    if not handlers then
        handlers = lib.array:new()
        stateChangeHandlers[key] = handlers
    end

    handlers:push({
        cb = handler,
        cookie = AddStateBagChangeHandler(key, '', triggerStateChangeHandlers),
    })
end

---@class PlayerConstructor
---@overload fun(self: Player, netId: number): Player
function Player:constructor(netId)
    if netId == -1 then netId = isServer and tonumber(GetPlayerFromIndex(0)) or cache.serverId end

    local playerId = isServer and netId or GetPlayerFromServerId(netId)

    self:super(0)
    self.playerId = playerId
    self:setHandle(GetPlayerPed(playerId))
end

function Player:__index(index)
    if index == 'handle' then
        return isServer and self.private.handle or GetPlayerPed(self.playerId)
    end

    return Player[index]
end

---@param model string | number
function Player:setModel(model)
    SetPlayerModel(self.playerId, model)
end

function Player:getRoutingBucket()
    ---@diagnostic disable-next-line: param-type-mismatch
    return isServer and GetPlayerRoutingBucket(self.playerId) or self:get('bucket') or 0
end

---@param bucket number
function Player:setRoutingBucket(bucket)
    if not isServer then return end

    ---@diagnostic disable-next-line: param-type-mismatch
    SetPlayerRoutingBucket(self.playerId, bucket)
    self:set('bucket', bucket, 1)
end

if not isServer then
    Player.Local = Player:new(-1)
end

return Player
