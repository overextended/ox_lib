---@diagnostic disable: invisible
lib.print.warn('ox_lib\'s class module is experimental and may break without warning.')

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

---@class OxClass
---@field protected __name string
---@field protected private table
---@field protected super function
---@field protected constructor function
local mixins = {}
local constructors = {}
local getinfo = debug.getinfo

---Somewhat hacky way to remove the constructor from the class.__index.
---Maybe add static fields in the future?
local function getConstructor(class)
    local constructor = constructors[class] or class.constructor

    if class.constructor then
        constructors[class] = class.constructor
        class.constructor = nil
    end

    return constructor
end

local function void() return '' end

---Creates a new instance of the given class.
---@generic T
---@param class T
---@return T
function mixins.new(class, ...)
    ---@cast class +OxClass
    local constructor = getConstructor(class)
    local obj = {
        private = {}
    }

    if not constructor and table.type(...) == 'hash' then
        lib.print.warn(([[Creating instance of %s with a table and no constructor.
This behaviour is deprecated and will not be supported in the future.]])
            :format(class.__name))

        obj = ...

        if obj.private then
            assertType('private', obj.private, 'table')
        end
    end

    setmetatable(obj, class)

    if constructor and obj ~= ... then
        local parent = class

        function obj:super(...)
            parent = getmetatable(parent)
            constructor = getConstructor(parent)

            if constructor then return constructor(self, ...) end
        end

        constructor(obj, ...)
    elseif class.init then
        lib.print.warn(([[Calling %s:init() is deprecated and will not be supported in the future.
Use %s:constructor(...args) and assign properties in the constructor.]])
            :format(class.__name, class.__name))

        obj:init()
    end

    obj.super = nil

    if next(obj.private) then
        local private = table.clone(obj.private)

        table.wipe(obj.private)
        setmetatable(obj.private, {
            __metatable = 'private',
            __tostring = void,
            __index = function(self, index)
                local di = getinfo(2, 'n')

                if di.namewhat ~= 'method' then return end

                return private[index]
            end,
            __newindex = function(self, index, value)
                local di = getinfo(2, 'n')

                if di.namewhat ~= 'method' then
                    error(("cannot set values on private field '%s'"):format(index), 2)
                end

                private[index] = value
            end
        })
    else
        obj.private = nil
    end

    ---@cast class -OxClass
    return obj
end

---Checks if an object is an instance of the given class.
---@param obj table
---@param class OxClass
function mixins.isClass(obj, class)
    return getmetatable(obj) == class
end

---Checks if an object is an instance or derivative of the given class.
---@param obj table
---@param class OxClass
function mixins.instanceOf(obj, class)
    local mt = getmetatable(obj)

    while mt do
        if mt == class then return true end

        mt = getmetatable(mt)
    end

    return false
end

---Creates a new class.
---@generic S : OxClass
---@param name string
---@param super? S
function lib.class(name, super)
    assertType(1, name, 'string')

    local class = table.clone(mixins)

    class.__name = name
    ---@diagnostic disable-next-line: inject-field
    class.__index = class

    if super then
        assertType('super', super, 'table')
        setmetatable(class, super)
    end

    ---@todo See if there's a way we can auto-create a class using the name and super
    return class
end

return lib.class
