--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---Seat index for vehicle natives. Accepts the `eSeatPosition` enum constants
---(`-2 = SF_ANY`, `-1 = driver`, `0 = front passenger`, …) or any raw integer.
---@alias SeatPosition eSeatPosition | number

---@class VehicleInitClient
---@field model string | number Model name or precomputed hash.
---@field coords vector3 Spawn coordinate.
---@field heading? number Heading the vehicle should face, in degrees.
---@field isNetwork? boolean Whether to create a network vehicle. Default `false`.
---@field netMissionEntity? boolean **GTA5 only.** Pin to script host. Default `false`.
---@field bScriptHostVeh? boolean **RedM only.** Pin to script host. Default `false`.
---@field bDontAutoCreateDraftAnimals? boolean **RedM only.** Skip auto-creation of draft animals. Default `false`.
---@field p8? boolean **RedM only.** Undocumented. Default `false`.
---@field properties? table **GTA5 only.** Properties applied via `lib.setVehicleProperties` after spawning.

---Client-side spawnable vehicle.
---@class VehicleClient : Entity
local VehicleClient = lib.class('VehicleClient', lib.entity)

---@param data VehicleInitClient
function VehicleClient:constructor(data)
    assert(type(data) == 'table', 'expected table init data')
    assert(data.coords and data.coords.x and data.coords.y and data.coords.z, 'expected vector3 coords')
    assert(type(data.model) == 'string' or type(data.model) == 'number', 'expected string or number model')

    local handle, modelHash = lib.entity.createClient(VehicleClient.spawn, data, 'ox_lib:createVehicle', 'vehicle')

    self:super(handle)

    self.private.spawnData = data
    self.private.modelHash = modelHash

    if data.properties and cache.game ~= 'redm' then
        lib.setVehicleProperties(handle, data.properties)
    end
end

---@protected
---@param modelHash number
---@param data VehicleInitClient
---@return number handle
function VehicleClient.spawn(modelHash, data)
    local headingValue = data.heading and data.heading + 0.0 or 0.0

    if cache.game == 'redm' then
        return CreateVehicle(modelHash, data.coords.x, data.coords.y, data.coords.z, headingValue,
            data.isNetwork or false, data.bScriptHostVeh or false,
            data.bDontAutoCreateDraftAnimals or false, data.p8 or false)
    end

    return CreateVehicle(modelHash, data.coords.x, data.coords.y, data.coords.z, headingValue, data.isNetwork or false, data.netMissionEntity or false)
end

---Apply vehicle properties via `lib.setVehicleProperties`. GTA5 only — no-op on RedM.
---@param properties table
function VehicleClient:setProperties(properties)
    if cache.game == 'redm' then return end
    lib.setVehicleProperties(self.handle, properties)
    if self.private and self.private.spawnData then
        self.private.spawnData.properties = properties
    end
end

---@protected
---Re-applies stored vehicle properties after the entity is re-spawned (GTA5 only).
---@param data table
function VehicleClient:onAfterRespawn(data)
    if data.properties and cache.game ~= 'redm' then
        lib.setVehicleProperties(self.handle, data.properties)
    end
end

---Warp a ped into one of this vehicle's seats. Client-only; uses `TaskWarpPedIntoVehicle`.
---@param ped number | Entity Ped handle or wrapper instance.
---@param seat? SeatPosition Seat index. Default `-1` (driver).
---@return boolean
function VehicleClient:warpPed(ped, seat)
    local pedHandle = type(ped) == 'table' and ped.handle or ped --[[@as number]]
    seat = seat or -1 --[[@as number]]
    if not IsVehicleSeatFree(self.handle, seat) then return false end
    TaskWarpPedIntoVehicle(pedHandle, self.handle, seat)
    return true
end

lib.vehicle = VehicleClient

return lib.vehicle
