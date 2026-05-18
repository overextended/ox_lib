--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---Vehicle category for `CreateVehicleServerSetter` (GTA5 only).
---@alias VehicleType
---| 'automobile'
---| 'bike'
---| 'boat'
---| 'heli'
---| 'plane'
---| 'submarine'
---| 'trailer'
---| 'train'

---@class VehicleInitServer
---@field model string | number Model name or precomputed hash.
---@field coords vector3 Spawn coordinate.
---@field heading? number Heading the vehicle should face, in degrees.
---@field type? VehicleType **GTA5 only.** Vehicle category passed to `CreateVehicleServerSetter`. Default `'automobile'`.
---@field properties? table **GTA5 only.** Properties applied via `lib.setVehicleProperties` after spawning.
---@field orphanMode? EntityOrphanMode Server-side cleanup behavior. Default `2` (KeepEntity).

---Server-side spawnable vehcle.
---@class VehicleServer : Entity
local VehicleServer = lib.class('VehicleServer', lib.entity)

---@param data VehicleInitServer
function VehicleServer:constructor(data)
    assert(type(data) == 'table', 'expected table init data')
    assert(data.coords and data.coords.x and data.coords.y and data.coords.z, 'expected vector3 coords')
    assert(type(data.model) == 'string' or type(data.model) == 'number', 'expected string or number model')

    local handle, modelHash = lib.entity.createServer(VehicleServer.spawn, data, 'vehicle')

    self:super(handle)

    self.private.spawnData = data
    self.private.modelHash = modelHash

    if cache.game ~= 'redm' then
        self:setOrphanMode(data.orphanMode or 2)

        if data.properties then
            lib.setVehicleProperties(handle, data.properties)
        end
    end
end

---@protected
---@param modelHash number
---@param data VehicleInitServer
---@return number handle
function VehicleServer.spawn(modelHash, data)
    local headingValue = data.heading and data.heading + 0.0 or 0.0

    if cache.game == 'redm' then
        return CreateVehicle(modelHash, data.coords.x, data.coords.y, data.coords.z, headingValue, true, true)
    end

    return CreateVehicleServerSetter(modelHash, data.type or 'automobile', data.coords.x, data.coords.y, data.coords.z, headingValue)
end

---Place a ped into one of this vehicle's seats. Uses the server-side
---`SetPedIntoVehicle` native (no `TaskWarpPedIntoVehicle` on the server).
---@param ped number | Entity Ped handle or wrapper instance.
---@param seat? number Seat index. Default `-1` (driver).
function VehicleServer:placePed(ped, seat)
    local pedHandle = type(ped) == 'table' and ped.handle or ped --[[@as number]]
    SetPedIntoVehicle(pedHandle, self.handle, seat or -1)
end

---Apply vehicle properties via `lib.setVehicleProperties`. GTA5 only — no-op on RedM.
---@param properties table
function VehicleServer:setProperties(properties)
    if cache.game == 'redm' then return end
    lib.setVehicleProperties(self.handle, properties)
    if self.private and self.private.spawnData then
        self.private.spawnData.properties = properties
    end
end

---@protected
---Re-applies stored vehicle properties after the entity is re-spawned (GTA5 only).
---@param data table
function VehicleServer:onAfterRespawn(data)
    if data.properties and cache.game ~= 'redm' then
        lib.setVehicleProperties(self.handle, data.properties)
    end
end

lib.vehicle = VehicleServer

lib.entity.registerCreateCallback(VehicleServer, 'ox_lib:createVehicle', 'vehicle')

return lib.vehicle
