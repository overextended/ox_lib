--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@meta Ox.Game.Vehicle

local GameEntity = require 'Ox.Game.Entity'
local isServer = lib.context == 'server'

---@alias VehicleType 'automobile' | 'bike' | 'boat' | 'heli' | 'plane' | 'submarine' | 'trailer' | 'train'

---@class Vehicle : GameEntity
---@field new VehicleConstructor
Vehicle = Class('Vehicle', GameEntity)
Vehicle.type = Vehicle.__name

---@param model string | number
---@param x number
---@param y number
---@param z number
---@param heading? number
---@param isNetworked? boolean client defaults to false; does nothing on the server.
---@param netMissionEntity? boolean client defaults to false; does nothing on the server.
---@return Vehicle
---@see CreateVehicle
function Vehicle.create(model, x, y, z, heading, isNetworked, netMissionEntity)
    heading = heading or 0
    isNetworked = isServer or isNetworked or false
    netMissionEntity = isServer or netMissionEntity or false
    local hash = isServer and model or lib.requestModel(model)
    local handle = CreateVehicle(hash, x, y, z, heading, isNetworked, netMissionEntity)

    ---@todo Lazy vehicle type handling
    ---CreateVehicleServerSetter(hash, type, x, y, z, heading)

    if not isServer then SetModelAsNoLongerNeeded(hash) end

    return Vehicle:new(handle)
end

---@class VehicleConstructor
---@overload fun(self: Vehicle, handle: number): Vehicle
function Vehicle:constructor(handle)
    self:super()
    self:setHandle(handle)
end

function Vehicle:__index(index)
    if index == 'handle' then
        return self.private.handle
    end

    return Vehicle[index]
end

---@return VehicleType
function Vehicle:getType()
    return GetVehicleType(self.handle)
end

function Vehicle:getPlate()
    return GetVehicleNumberPlateText(self.handle)
end

---@param plate string
function Vehicle:setPlate(plate)
    SetVehicleNumberPlateText(self.handle, plate)
end

function Vehicle:setOnGround()
    if isServer then
        return self:setr('ox_entity_setonground', true)
    end

    return SetVehicleOnGroundProperly(self.handle)
end

return Vehicle
