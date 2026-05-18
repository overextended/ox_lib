--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class PedInitClient
---@field model string | number Model name or precomputed hash.
---@field coords vector3 Spawn coordinate.
---@field heading? number Heading the ped should face, in degrees.
---@field isNetwork? boolean Whether to create a network ped. Default `false`.
---@field bScriptHostPed? boolean Pin to script host. Default `false`.
---@field pedType? number **GTA5 only.** AI behavior type. 4 = CIVMALE, etc. Default 0.
---@field p7? boolean **RedM only.** Undocumented. Default `false`.
---@field p8? boolean **RedM only.** Undocumented. Default `false`.

---Client-side spawnable ped.
---@class PedClient : Entity
local PedClient = lib.class('PedClient', lib.entity)

---@param data PedInitClient
function PedClient:constructor(data)
    assert(type(data) == 'table', 'expected table init data')
    assert(data.coords and data.coords.x and data.coords.y and data.coords.z, 'expected vector3 coords')
    assert(type(data.model) == 'string' or type(data.model) == 'number', 'expected string or number model')

    local handle, modelHash = lib.entity.createClient(PedClient.spawn, data, 'ox_lib:createPed', 'ped')

    self:super(handle)

    self.private.spawnData = data
    self.private.modelHash = modelHash
end

---@protected
---@param modelHash number
---@param data PedInitClient
---@return number handle
function PedClient.spawn(modelHash, data)
    local headingValue = data.heading and data.heading + 0.0 or 0.0

    if cache.game == 'redm' then
        return CreatePed(modelHash, data.coords.x, data.coords.y, data.coords.z, headingValue,
            data.isNetwork or false, data.bScriptHostPed or false, data.p7 or false, data.p8 or false)
    end

    return CreatePed(data.pedType or 0, modelHash, data.coords.x, data.coords.y, data.coords.z, headingValue,
        data.isNetwork or false, data.bScriptHostPed or false)
end

---Warp the ped into a vehicle seat. Client-only; uses `TaskWarpPedIntoVehicle`.
---@param vehicle number | Entity Vehicle handle or wrapper instance.
---@param seat? number Seat index. Default `-1` (driver).
function PedClient:warpInto(vehicle, seat)
    local vehicleHandle = type(vehicle) == 'table' and vehicle.handle or vehicle
    TaskWarpPedIntoVehicle(self.handle, vehicleHandle, seat or -1)
end

lib.ped = PedClient

return lib.ped
