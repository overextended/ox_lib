--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class Set : OxClass
---@field private new SetConstructor
local Set = lib.class('Set')

---@class SetConstructor
---@overload fun(self: Set, ...: any): Set
---@private
function Set:constructor(...)
    self.private.items = {}
    self.private.index = {}

    local n = select('#', ...)
    for i = 1, n do
        self:add((select(i, ...)))
    end
end

---@param value any
---@return Set self
function Set:add(value)
    if value == nil or self.private.index[value] then return self end
    local items = self.private.items
    local i = #items + 1
    items[i] = value
    self.private.index[value] = i
    return self
end

---@param value any
---@return boolean removed
function Set:remove(value)
    local i = self.private.index[value]
    if not i then return false end

    local items = self.private.items
    local lastI = #items

    if i ~= lastI then
        local last = items[lastI]
        items[i] = last
        self.private.index[last] = i
    end

    items[lastI] = nil
    self.private.index[value] = nil
    return true
end

---@param value any
---@return boolean
function Set:has(value)
    return self.private.index[value] ~= nil
end

---@return integer
function Set:size()
    return #self.private.items
end

---@return boolean
function Set:isEmpty()
    return #self.private.items == 0
end

---@return Set self
function Set:clear()
    self.private.items = {}
    self.private.index = {}
    return self
end

---@return fun(): any?
function Set:each()
    local items = self.private.items
    local i = 0
    return function()
        i += 1
        return items[i]
    end
end

function Set:__pairs()
    return self:each(), nil, nil
end

Set.__len = Set.size

---@return Array
function Set:toArray()
    return lib.array:from(self.private.items)
end

---@param other Set
---@return Set
function Set:union(other)
    local result = Set:new()
    local items = self.private.items
    for i = 1, #items do result:add(items[i]) end
    for v in other:each() do result:add(v) end
    return result
end

---@param other Set
---@return Set
function Set:intersection(other)
    local result = Set:new()
    local items = self.private.items
    for i = 1, #items do
        if other:has(items[i]) then result:add(items[i]) end
    end
    return result
end

---@param other Set
---@return Set
function Set:difference(other)
    local result = Set:new()
    local items = self.private.items
    for i = 1, #items do
        if not other:has(items[i]) then result:add(items[i]) end
    end
    return result
end

---@param other Set
---@return boolean
function Set:equals(other)
    if #self.private.items ~= other:size() then return false end
    local items = self.private.items
    for i = 1, #items do
        if not other:has(items[i]) then return false end
    end
    return true
end

---@param other Set
---@return boolean
function Set:isSubsetOf(other)
    if #self.private.items > other:size() then return false end
    local items = self.private.items
    for i = 1, #items do
        if not other:has(items[i]) then return false end
    end
    return true
end

lib.set = Set
return lib.set
