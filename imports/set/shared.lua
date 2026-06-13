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
    self.private.items = {}
    self.private.index = {}

    local args = { ... }
    for i = 1, select('#', ...) do
        self:add(args[i])
    end
end

---@param value any
---@return Set self
function lib.set:add(value)
    if value == nil or self.private.index[value] then return self end
    local items = self.private.items
    local i = #items + 1
    items[i] = value
    self.private.index[value] = i
    return self
end

---@param value any
---@return boolean removed
function lib.set:remove(value)
    local i = self.private.index[value]
    if not i then return false end

    local items = self.private.items
    local lastI = #items

    if i ~= lastI then
        table.move(items, i + 1, lastI, i)
        for j = i, lastI - 1 do
            self.private.index[items[j]] = j
        end
    end

    items[lastI] = nil
    self.private.index[value] = nil
    return true
end

---@param value any
---@return boolean
function lib.set:has(value)
    return self.private.index[value] ~= nil
end

---@return integer
function lib.set:size()
    return #self.private.items
end

---@return boolean
function lib.set:isEmpty()
    return #self.private.items == 0
end

---@return Set self
function lib.set:clear()
    table.wipe(self.private.items)
    table.wipe(self.private.index)
    return self
end

---@return fun(): any?
function lib.set:each()
    local items = self.private.items
    local i = 0
    return function()
        i += 1
        return items[i]
    end
end

function lib.set:__pairs()
    return self:each(), nil, nil
end

lib.set.__len = lib.set.size

---@return Array
function lib.set:toArray()
    return lib.array:from(self.private.items)
end

---@param other Set
---@return Set
function lib.set:union(other)
    local result = lib.set:new()
    local items = self.private.items
    for i = 1, #items do result:add(items[i]) end
    for v in other:each() do result:add(v) end
    return result
end

---@param other Set
---@return Set
function lib.set:intersection(other)
    local result = lib.set:new()
    local items = self.private.items
    for i = 1, #items do
        if other:has(items[i]) then result:add(items[i]) end
    end
    return result
end

---@param other Set
---@return Set
function lib.set:difference(other)
    local result = lib.set:new()
    local items = self.private.items
    for i = 1, #items do
        if not other:has(items[i]) then result:add(items[i]) end
    end
    return result
end

---@param other Set
---@return boolean
function lib.set:equals(other)
    if #self.private.items ~= other:size() then return false end
    local items = self.private.items
    for i = 1, #items do
        if not other:has(items[i]) then return false end
    end
    return true
end

---@param other Set
---@return boolean
function lib.set:isSubsetOf(other)
    if #self.private.items > other:size() then return false end
    local items = self.private.items
    for i = 1, #items do
        if not other:has(items[i]) then return false end
    end
    return true
end

return lib.set
