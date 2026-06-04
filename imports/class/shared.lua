--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@diagnostic disable: invisible
local getinfo = debug.getinfo

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

local weakkeys = { __mode = 'k' }

---@type { [OxClass]: { [function]: true } }
local classes = setmetatable({}, weakkeys)

---@alias OxClassConstructor<T> fun(self: T, ...: unknown): nil

---@class OxClass
---@field private __index table
---@field protected __name string
---@field protected private? { [string]: unknown }
---@field protected super? OxClassConstructor
---@field protected constructor? OxClassConstructor
local mixins = {}
local constructors = setmetatable({}, weakkeys)

---Somewhat hacky way to remove the constructor from the class.__index.
---Maybe add static fields in the future?
---@param class OxClass
local function getConstructor(class)
    local constructor = constructors[class] or class.constructor

    if class.constructor then
        constructors[class] = class.constructor
        class.constructor = nil
    end

    return constructor
end

local function void() return '' end

---@param class OxClass
---@return boolean
local function validatePrivateAccess(class)
    local level = 3

    while true do
        local di = getinfo(level, 'f')

        if not di or not di.func then return false end

        local method = classes[class][di.func]

        if not method then
            for k, v in pairs(class) do
                if v == di.func then
                    method = v
                    classes[class][method] = k
                    break
                end
            end
        end

        if method then return true end

        level += 1
    end
end

---Creates a new instance of the given class.
---@protected
---@generic T
---@param class T | OxClass
---@return T
function mixins.new(class, ...)
    local constructor = getConstructor(class)
    local private = {}
    local obj = setmetatable({ private = private }, class)

    if constructor then
        local parent = class

        rawset(obj, 'super', function(self, ...)
            parent = getmetatable(parent)
            constructor = getConstructor(parent)

            if constructor then return constructor(self, ...) end
        end)

        constructor(obj, ...)
    end

    rawset(obj, 'super', nil)

    if private ~= obj.private or next(obj.private) then
        private = table.clone(obj.private)

        table.wipe(obj.private)
        setmetatable(obj.private, {
            __metatable = 'private',
            __tostring = void,
            __index = function(self, index)
                if not validatePrivateAccess(class) then return end

                return private[index]
            end,
            __newindex = function(self, index, value)
                if not validatePrivateAccess(class) then
                    error(("cannot set value of private field '%s'"):format(index), 2)
                end

                private[index] = value
            end
        })
    else
        obj.private = nil
    end

    return obj
end

---Checks if an object is an instance of the given class.
---@param class OxClass
function mixins:isClass(class)
    return getmetatable(self) == class
end

---Checks if an object is an instance or derivative of the given class.
---@param class OxClass
function mixins:instanceOf(class)
    local mt = getmetatable(self)

    while mt do
        if mt == class then return true end

        mt = getmetatable(mt)
    end

    return false
end

---Creates a new class.
---@generic S : OxClass
---@generic T : string
---@param name `T`
---@param super? S
---@return `T`
function lib.class(name, super)
    assertType(1, name, 'string')

    local class = table.clone(mixins)

    class.__name = name
    class.__index = class

    if super then
        assertType('super', super, 'table')
        setmetatable(class, super)
    end

    classes[class] = setmetatable({}, weakkeys)

    return class
end

return lib.class
