--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class Set : OxClass
---@field private new SetConstructor
local Set = lib.class('Set')

---@class SetConstructor
---@overload fun(self: Set, values?: any[]): Set
---@private
---@param values? any[]
function Set:constructor(values)
    self.private.items = {}
    self.private.count = 0

    if values then
        for i = 1, #values do
            local v = values[i]
            if not self.private.items[v] then
                self.private.items[v] = true
                self.private.count += 1
            end
        end
    end
end

---@param value any
---@return Set self
function Set:add(value)
    if not self.private.items[value] then
        self.private.items[value] = true
        self.private.count += 1
    end
    return self
end

---@param value any
---@return boolean removed
function Set:remove(value)
    if not self.private.items[value] then return false end
    self.private.items[value] = nil
    self.private.count -= 1
    return true
end

---@param value any
---@return boolean
function Set:has(value)
    return self.private.items[value] ~= nil
end

---@return integer
function Set:size()
    return self.private.count
end

---@return boolean
function Set:isEmpty()
    return self.private.count == 0
end

---@return Set self
function Set:clear()
    self.private.items = {}
    self.private.count = 0
    return self
end

---@return fun(): any?
function Set:each()
    local items = self.private.items
    local k
    return function()
        k = next(items, k)
        return k
    end
end

---@return Array
function Set:toArray()
    return lib.array:from(self:each())
end

---@param other Set
---@return Set
function Set:union(other)
    local result = lib.set(self:toArray())
    for v in other:each() do result:add(v) end
    return result
end

---@param other Set
---@return Set
function Set:intersection(other)
    local result = lib.set()
    for v in self:each() do
        if other:has(v) then result:add(v) end
    end
    return result
end

---@param other Set
---@return Set
function Set:difference(other)
    local result = lib.set()
    for v in self:each() do
        if not other:has(v) then result:add(v) end
    end
    return result
end

---@param other Set
---@return boolean
function Set:equals(other)
    if self.private.count ~= other:size() then return false end
    for v in self:each() do
        if not other:has(v) then return false end
    end
    return true
end

---@param other Set
---@return boolean
function Set:isSubsetOf(other)
    if self.private.count > other:size() then return false end
    for v in self:each() do
        if not other:has(v) then return false end
    end
    return true
end

lib.set = Set
return lib.set
