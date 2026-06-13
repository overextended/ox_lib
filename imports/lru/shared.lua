--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class LruNode
---@field key any
---@field value any
---@field prev? LruNode
---@field next? LruNode

---@class Lru : OxClass
---@field private new LruConstructor
lib.lru = lib.class('Lru')

local function detach(self, node)
    local prev, nxt = node.prev, node.next
    if prev then prev.next = nxt else self.private.head = nxt end
    if nxt then nxt.prev = prev else self.private.tail = prev end
    node.prev = nil
    node.next = nil
end

local function attachHead(self, node)
    node.prev = nil
    node.next = self.private.head
    if self.private.head then self.private.head.prev = node end
    self.private.head = node
    if not self.private.tail then self.private.tail = node end
end

---@class LruConstructor
---@overload fun(self: Lru, capacity: integer): Lru
---@private
---@param capacity integer
function lib.lru:constructor(capacity)
    if type(capacity) ~= 'number' or capacity < 1 or capacity % 1 ~= 0 then
        error("capacity must be a positive integer", 2)
    end

    self.private.capacity = capacity
    self.private.map = {}
    self.private.count = 0
    self.private.head = nil
    self.private.tail = nil
end

---@param key any
---@return any?
function lib.lru:get(key)
    local node = self.private.map[key]
    if not node then return nil end
    detach(self, node)
    attachHead(self, node)
    return node.value
end

---@param key any
---@param value any
---@return any? evictedKey
---@return any? evictedValue
function lib.lru:set(key, value)
    local node = self.private.map[key]

    if node then
        node.value = value
        detach(self, node)
        attachHead(self, node)
        return nil
    end

    node = { key = key, value = value }
    self.private.map[key] = node
    attachHead(self, node)
    self.private.count += 1

    if self.private.count > self.private.capacity then
        local evicted = self.private.tail
        detach(self, evicted)
        self.private.map[evicted.key] = nil
        self.private.count -= 1
        return evicted.key, evicted.value
    end
end

---@param key any
---@return boolean
function lib.lru:has(key)
    return self.private.map[key] ~= nil
end

---@param key any
---@return any?
function lib.lru:peek(key)
    local node = self.private.map[key]
    if not node then return nil end
    return node.value
end

---@param key any
---@return boolean removed
function lib.lru:delete(key)
    local node = self.private.map[key]
    if not node then return false end
    detach(self, node)
    self.private.map[key] = nil
    self.private.count -= 1
    return true
end

---@return integer
function lib.lru:size()
    return self.private.count
end

---@return integer
function lib.lru:capacity()
    return self.private.capacity
end

---@return Lru self
function lib.lru:clear()
    self.private.map = {}
    self.private.head = nil
    self.private.tail = nil
    self.private.count = 0
    return self
end

---@return fun(): any?, any?
function lib.lru:each()
    local node = self.private.head
    return function()
        if not node then return nil end
        local k, v = node.key, node.value
        node = node.next
        return k, v
    end
end

function lib.lru:__pairs()
    return self:each(), nil, nil
end

lib.lru.__len = lib.lru.size

return lib.lru
