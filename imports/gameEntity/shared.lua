--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class GameEntity : OxStateBag
---@field handle number
---@field netId number
---@field protected private { handle: number }
---@field private new GameEntityConstructor
lib.gameEntity = lib.class('GameEntity', lib.stateBag)

---@class GameEntityConstructor
---@overload fun(self: GameEntity, handle: number): GameEntity
---@private
function lib.gameEntity:constructor(handle)
    self:super()
    self.private.handle = handle or 0
end

function lib.gameEntity:__index(index)
    if index == 'handle' then
        return self.private.handle
    end

    return lib.gameEntity[index]
end

function lib.gameEntity:setHandle(handle)
    self.private.handle = handle
    self.netId = NetworkGetNetworkIdFromEntity(handle)
    self.statebag = (self.netId == 0 and 'localEntity:%s' or self.__name == 'Player' and 'player:%s' or 'entity:%s'):format(handle)

    if (self.netId == 0 or cache.game == 'fxserver') and self.__name == 'Player' then
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

return lib.gameEntity
