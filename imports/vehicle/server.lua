---@diagnostic disable: duplicate-set-field

---@private
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

    return lib.vehicle:new(handle)
end
