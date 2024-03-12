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
        error(("expected %s %s to have type '%s' (received %s)")
            :format(type(id) == 'string' and 'field' or 'argument', id, expected, received), 3)
    end

    if expected == 'table' and table.type(var) ~= 'hash' then
        error(("expected argument %s to have table.type 'hash' (received %s)")
            :format(id, table.type(var)), 3)
    end

    return true
end

local mixins = {}

---Creates a new instance of the given class.
function mixins.new(class, obj)
    if obj.private then
        assertType('private', obj.private, 'table')
        setmetatable(obj.private, private_mt)
    end

    setmetatable(obj, class)

    if class.init then
        local parent = class

        function obj:super(...)
            parent = getmetatable(parent)
            local superInit = parent and parent.init

            if superInit then return superInit(self, ...) end
        end

        obj:init()
        obj.super = nil
    end

    return obj
end

---Checks if an object is an instance of the given class.
function mixins.isClass(obj, class)
    return getmetatable(obj) == class
end

---Checks if an object is an instance or derivative of the given class.
function mixins.instanceOf(obj, class)
    local mt = getmetatable(obj)

    while mt do
        if mt == class then return true end

        mt = getmetatable(mt)
    end

    return false
end

---Creates a new class.
---@todo add inherited types for new/private/init fields (not yet supported by lls)
---@param name string
---@param super? table
function lib.class(name, super)
    assertType(1, name, 'string')

    local class = table.clone(mixins)

    class.__name = name
    class.__index = class

    if super then
        assertType('super', super, 'table')
        setmetatable(class, super)
    end

    return class
end

return lib.class
