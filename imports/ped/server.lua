--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class PedInitServer
---@field model string | number Model name or precomputed hash.
---@field coords vector3 Spawn coordinate.
---@field heading? number Heading the ped should face, in degrees.
---@field pedType? number **GTA5 only.** AI behavior type. 4 = CIVMALE, 5 = CIVFEMALE, etc. Default 0. Ignored on RedM.
---@field orphanMode? EntityOrphanMode Server-side cleanup behavior. Default `2` (KeepEntity).

---Server-side spawnable ped.
---@class PedServer : Entity
local PedServer = lib.class('PedServer', lib.entity)

---@param data PedInitServer
function PedServer:constructor(data)
    assert(type(data) == 'table', 'expected table init data')
    assert(data.coords and data.coords.x and data.coords.y and data.coords.z, 'expected vector3 coords')
    assert(type(data.model) == 'string' or type(data.model) == 'number', 'expected string or number model')

    local handle, modelHash = lib.entity.createServer(PedServer.spawn, data, 'ped')

    self:super(handle)

    self.private.spawnData = data
    self.private.modelHash = modelHash

    if cache.game ~= 'redm' then
        self:setOrphanMode(data.orphanMode or 2)
    end
end

---@protected
---@param modelHash number
---@param data PedInitServer
---@return number handle
function PedServer.spawn(modelHash, data)
    local headingValue = data.heading and data.heading + 0.0 or 0.0

    if cache.game == 'redm' then
        -- RedM CFX CreatePed: pedType is `Unused` per the native docs but still required as the first arg.
        return CreatePed(0, modelHash, data.coords.x, data.coords.y, data.coords.z, headingValue, true, true)
    end

    return CreatePed(data.pedType or 0, modelHash, data.coords.x, data.coords.y, data.coords.z, headingValue, true, true)
end

---Place the ped into a vehicle seat. Uses the server-side `SetPedIntoVehicle` native
---(no `TaskWarpPedIntoVehicle` on the server).
---@param vehicle number | Entity Vehicle handle or wrapper instance.
---@param seat? number Seat index. Default `-1` (driver).
function PedServer:setIntoVehicle(vehicle, seat)
    local vehicleHandle = type(vehicle) == 'table' and vehicle.handle or vehicle
    SetPedIntoVehicle(self.handle, vehicleHandle, seat or -1)
end

lib.ped = PedServer

lib.entity.registerCreateCallback(PedServer, 'ox_lib:createPed', 'ped')

return lib.ped
