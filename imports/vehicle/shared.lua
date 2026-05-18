--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@alias VehicleType 'automobile' | 'bike' | 'boat' | 'heli' | 'plane' | 'submarine' | 'trailer' | 'train'

---@class Vehicle : GameEntity
---@field private new VehicleConstructor
lib.vehicle = lib.class('Vehicle', lib.gameEntity)

---@class VehicleConstructor
---@overload fun(self: Vehicle, handle: number): Vehicle
function lib.vehicle:constructor(handle)
    self:super()
    self:setHandle(handle)
end

function lib.vehicle:__index(index)
    if index == 'handle' then
        return self.private.handle
    end

    return lib.vehicle[index]
end

---@return VehicleType
function lib.vehicle:getType()
    return GetVehicleType(self.handle)
end

function lib.vehicle:getPlate()
    return GetVehicleNumberPlateText(self.handle)
end

---@param plate string
function lib.vehicle:setPlate(plate)
    SetVehicleNumberPlateText(self.handle, plate)
end

return lib.vehicle
