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
    print('priv?', self.private.handle)
    return GetEntityCoords(self.handle)
end

function lib.gameEntity:getModel()
    return GetEntityModel(self.handle)
end

return lib.gameEntity
