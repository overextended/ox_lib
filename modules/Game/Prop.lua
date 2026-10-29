--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@meta Ox.Game.Prop

local GameEntity = require 'Ox.Game.Entity'
local isServer = lib.context == 'server'

---@class Prop : GameEntity
---@field new PropConstructor
Prop = Class('Prop', GameEntity)
Prop.type = Prop.__name

if isServer then
    ---@param model string | number
    ---@param x number
    ---@param y number
    ---@param z number
    ---@param heading? number
    ---@param dynamic? boolean
    ---@return Prop
    ---@see CreateObjectNoOffset
    ---`server`
    function Prop.create(model, x, y, z, heading, dynamic)
        local handle = CreateObjectNoOffset(model, x, y, z, true, true, dynamic or false)
        local prop = Prop:new(handle)

        if heading then prop:setHeading(heading) end

        return prop
    end
else
    ---@param model string | number
    ---@param x number
    ---@param y number
    ---@param z number
    ---@param heading? number
    ---@param isNetworked? boolean
    ---@param netMissionEntity? boolean
    ---@param dynamic? boolean
    ---@return Prop
    ---@see CreateObject
    ---`client`
    function Prop.create(model, x, y, z, heading, isNetworked, netMissionEntity, dynamic)
        local hash = lib.requestModel(model)
        local handle = CreateObject(hash, x, y, z, isNetworked or false, netMissionEntity or false, dynamic or false)
        local prop = Prop:new(handle)

        SetModelAsNoLongerNeeded(hash)

        if heading then prop:setHeading(heading) end

        return prop
    end
end

---@class PropConstructor
---@overload fun(self: Prop, handle: number): Prop
function Prop:constructor(handle)
    self:super()
    self:setHandle(handle)
end

function Prop:__index(index)
    if index == 'handle' then
        return self.private.handle
    end

    return Prop[index]
end

function Prop:setOnGround()
    if isServer then
        return self:setr('ox_entity_setonground', true)
    end

    return PlaceObjectOnGroundProperly(self.handle)
end

return Prop
