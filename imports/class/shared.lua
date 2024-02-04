lib.print.warn('ox_lib\'s class module is experimental and may break without warning.')

-- Fields added to the "private" field on a class will not be msgpacked.
-- Use setters/getters when working with these values.
local private_mt = {
    __ext = 0,
    __pack = function() return '' end,
}

---Ensure the given argument or property has a valid type, otherwise throwing an error.
---@param id number | string
---@param var any
---@param expected type
local function assertType(id, var, expected)
    local received = type(var)

    if received ~= expected then
        error(("expected %s %s to have type '%s' (received %s)"):format(type(id) == 'string' and 'field' or 'argument', id, expected, received), 3)
    end

    return true
end

---Creates a new instance of the given class.
local function createObj(class, obj)
    if obj.private then
        assertType('private', obj.private, 'table')
        setmetatable(obj.private, private_mt)
    end

    setmetatable(obj, class)

    if class.init then obj:init() end

    return obj
end

---Creates a new class.
---@todo add inherited types for new/private/init fields (not yet supported by lls)
---@param name string
---@param super? table
function lib.class(name, super)
    assertType(1, name, 'string')

    local class = {
        __name = name,
        new = createObj,
    }

    class.__index = class

    return super and setmetatable(class, super) or class
end

return lib.class
