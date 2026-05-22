---@diagnostic disable: duplicate-set-field

---@private
---@param model string | number
---@param x number
---@param y number
---@param z number
---@param heading? number
---@return Ped
---@see CreatePed
---`server`
function lib.ped.create(model, x, y, z, heading)
    local handle = CreatePed(0, model, x, y, z, heading or 0, true, true)

    return lib.ped:new(handle)
end
