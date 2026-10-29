---@diagnostic disable: missing-fields
local Vehicle = require 'Ox.Game.Vehicle'

---@see Vehicle
---@deprecated
lib.vehicle = setmetatable(table.deepclone(Vehicle), Vehicle)

if lib.context == 'server' then
    ---@param model string | number
    ---@param type VehicleType
    ---@param x number
    ---@param y number
    ---@param z number
    ---@param heading? number
    ---@return Vehicle
    ---@see CreateVehicleServerSetter (FiveM)
    ---@see CreateVehicle (RedM)
    ---`server`
    function lib.vehicle.create(model, type, x, y, z, heading)
        heading = heading or 0
        local handle = CreateVehicleServerSetter
            and CreateVehicleServerSetter(model, type, x, y, z, heading)
            or CreateVehicle(model, x, y, z, heading, true, true)

        return Vehicle:new(handle)
    end
else
    ---@param model string | number
    ---@param x number
    ---@param y number
    ---@param z number
    ---@param heading? number
    ---@param isNetworked? boolean
    ---@param netMissionEntity? boolean
    ---@return Vehicle
    ---@see CreateVehicle
    ---`client`
    function lib.vehicle.create(model, x, y, z, heading, isNetworked, netMissionEntity)
        local hash = lib.requestModel(model)
        local handle = CreateVehicle(hash, x, y, z, heading or 0, isNetworked or false, netMissionEntity or false)

        SetModelAsNoLongerNeeded(hash)

        return Vehicle:new(handle)
    end
end

return lib.vehicle
