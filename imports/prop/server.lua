---@diagnostic disable: duplicate-set-field

---@private
---@param model string | number
---@param x number
---@param y number
---@param z number
---@param heading? number
---@param dynamic? boolean
---@return Prop
---@see CreateObjectNoOffset
---`server`
function lib.prop.create(model, x, y, z, heading, dynamic)
    local handle = CreateObjectNoOffset(model, x, y, z, true, true, dynamic or false)
    local prop = lib.prop:new(handle)

    if heading then prop:setHeading(heading) end

    return prop
end

return lib.prop
