--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class Prop : GameEntity
---@field private new ObjectConstructor
lib.prop = lib.class('Prop', lib.gameEntity)

---@class ObjectConstructor
---@overload fun(self: Prop, handle: number): Prop
function lib.prop:constructor(handle)
    self:super()
    self:setHandle(handle)
end

function lib.prop:__index(index)
    if index == 'handle' then
        return self.private.handle
    end

    return lib.prop[index]
end

function lib.prop:setOnGround()
    if lib.context == 'client' then
        return PlaceObjectOnGroundProperly(self.handle)
    end

    return self:setr('ox_entity_setonground', true)
end
