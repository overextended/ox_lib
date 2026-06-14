--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class Set : OxClass
---@field private new SetConstructor
lib.set = lib.class('Set')

---@class SetConstructor
---@overload fun(self: Set, ...: any): Set
---@private
function lib.set:constructor(...)
    self.private.map = lib.map:new()

    local args = { ... }
    for i = 1, select('#', ...) do
        self:add(args[i])
    end
end

---@param value any
---@return Set self
function lib.set:add(value)
    if value ~= nil and not self.private.map:has(value) then
        self.private.map:set(value, true)
    end
    return self
end

---@param value any
---@return boolean removed
function lib.set:remove(value)
    return self.private.map:delete(value)
end

---@param value any
---@return boolean
function lib.set:has(value)
    return self.private.map:has(value)
end

---@return integer
function lib.set:size()
    return self.private.map:size()
end

---@return boolean
function lib.set:isEmpty()
    return self.private.map:isEmpty()
end

---@return Set self
function lib.set:clear()
    self.private.map:clear()
    return self
end

---@return fun(): any?
function lib.set:each()
    return self.private.map:keys()
end

function lib.set:__pairs()
    local it = self.private.map:keys()
    local i = 0
    return function()
        local v = it()
        if v == nil then return nil end
        i += 1
        return i, v
    end
end

lib.set.__ipairs = lib.set.__pairs
lib.set.__len = lib.set.size

---@return Array
function lib.set:toArray()
    return lib.array:from(self:each())
end

---@param other Set
---@return Set
function lib.set:union(other)
    local result = lib.set:new()
    for v in self:each() do result:add(v) end
    for v in other:each() do result:add(v) end
    return result
end

---@param other Set
---@return Set
function lib.set:intersection(other)
    local result = lib.set:new()
    for v in self:each() do
        if other:has(v) then result:add(v) end
    end
    return result
end

---@param other Set
---@return Set
function lib.set:difference(other)
    local result = lib.set:new()
    for v in self:each() do
        if not other:has(v) then result:add(v) end
    end
    return result
end

---@param other Set
---@return boolean
function lib.set:equals(other)
    if self:size() ~= other:size() then return false end
    for v in self:each() do
        if not other:has(v) then return false end
    end
    return true
end

---@param other Set
---@return boolean
function lib.set:isSubsetOf(other)
    if self:size() > other:size() then return false end
    for v in self:each() do
        if not other:has(v) then return false end
    end
    return true
end

return lib.set
