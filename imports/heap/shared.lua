--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class Heap : OxClass
---@field private new HeapConstructor
local Heap = lib.class('Heap')

local function defaultLess(a, b) return a < b end

local function siftUp(items, i, lt)
    while i > 1 do
        local parent = i >> 1
        if not lt(items[i], items[parent]) then return end
        items[i], items[parent] = items[parent], items[i]
        i = parent
    end
end

local function siftDown(items, i, n, lt)
    while true do
        local left = i * 2
        if left > n then return end

        local smallest = i
        if lt(items[left], items[smallest]) then smallest = left end

        local right = left + 1
        if right <= n and lt(items[right], items[smallest]) then smallest = right end

        if smallest == i then return end

        items[i], items[smallest] = items[smallest], items[i]
        i = smallest
    end
end

---@class HeapConstructor
---@overload fun(self: Heap, comparator?: fun(a: any, b: any): boolean): Heap
---@private
---@param comparator? fun(a: any, b: any): boolean Returns true when `a` should come before `b`. Defaults to `a < b` (min-heap).
function Heap:constructor(comparator)
    if comparator ~= nil and type(comparator) ~= 'function' then
        error("comparator must be a function or nil", 2)
    end

    self.private.items = {}
    self.private.lt = comparator or defaultLess
end

---@param ... any
---@return Heap self
function Heap:push(...)
    local items = self.private.items
    local lt = self.private.lt
    local n = select('#', ...)

    for i = 1, n do
        items[#items + 1] = (select(i, ...))
        siftUp(items, #items, lt)
    end

    return self
end

---@return any?
function Heap:pop()
    local items = self.private.items
    local n = #items
    if n == 0 then return nil end

    local top = items[1]

    if n == 1 then
        items[1] = nil
    else
        items[1] = items[n]
        items[n] = nil
        siftDown(items, 1, n - 1, self.private.lt)
    end

    return top
end

---@return any?
function Heap:peek()
    return self.private.items[1]
end

---@return integer
function Heap:size()
    return #self.private.items
end

---@return boolean
function Heap:isEmpty()
    return #self.private.items == 0
end

---@return Heap self
function Heap:clear()
    self.private.items = {}
    return self
end

---@return Array sorted Newly-allocated array drained in pop order.
function Heap:drain()
    local out = lib.array:new()
    local n = 0
    while #self.private.items > 0 do
        n += 1
        out[n] = self:pop()
    end
    return out
end

Heap.__len = Heap.size

lib.heap = Heap
return lib.heap
