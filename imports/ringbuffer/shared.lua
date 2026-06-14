--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@diagnostic disable: invisible

---@class RingBuffer : OxClass
---@field private new RingBufferConstructor
lib.ringbuffer = lib.class('RingBuffer')

---@class RingBufferConstructor
---@overload fun(self: RingBuffer, capacity: integer): RingBuffer
---@private
---@param capacity integer
function lib.ringbuffer:constructor(capacity)
    if type(capacity) ~= 'number' or capacity < 1 or capacity % 1 ~= 0 then
        error("capacity must be a positive integer", 2)
    end

    self.private.items = table.create(capacity, 0)
    self.private.capacity = capacity
    self.private.count = 0
    self.private.nextIndex = 1
end

---@param value any
---@return any? evicted Value that was overwritten, if the buffer was full.
function lib.ringbuffer:push(value)
    local items = self.private.items ---@type any[]
    local capacity = self.private.capacity ---@type integer
    local nextIndex = self.private.nextIndex ---@type integer

    local evicted ---@type any?
    if self.private.count == capacity then
        evicted = items[nextIndex]
    else
        self.private.count += 1
    end

    items[nextIndex] = value
    self.private.nextIndex = nextIndex % capacity + 1

    return evicted
end

---@param self RingBuffer
---@return integer
local function oldestIndex(self)
    if self.private.count < self.private.capacity then return 1 end
    return self.private.nextIndex
end

---@param i integer Positive index from the oldest (1 = oldest); negative from the newest (-1 = newest).
---@return any?
function lib.ringbuffer:get(i)
    if type(i) ~= 'number' or i % 1 ~= 0 then
        error("index must be an integer", 2)
    end

    local count = self.private.count ---@type integer
    if i < 0 then i = count + i + 1 end
    if i < 1 or i > count then return nil end

    local start = oldestIndex(self) ---@type integer
    local capacity = self.private.capacity ---@type integer
    return self.private.items[((start - 1 + i - 1) % capacity) + 1]
end

---@return integer
function lib.ringbuffer:size()
    return self.private.count
end

---@return integer
function lib.ringbuffer:capacity()
    return self.private.capacity
end

---@return boolean
function lib.ringbuffer:isFull()
    return self.private.count == self.private.capacity
end

---@return boolean
function lib.ringbuffer:isEmpty()
    return self.private.count == 0
end

---@return RingBuffer self
function lib.ringbuffer:clear()
    table.wipe(self.private.items)
    self.private.count = 0
    self.private.nextIndex = 1
    return self
end

---@return fun(): any?
function lib.ringbuffer:each()
    local count = self.private.count ---@type integer
    local capacity = self.private.capacity ---@type integer
    local items = self.private.items ---@type any[]
    local start = oldestIndex(self) ---@type integer
    local i = 0 ---@type integer

    return function()
        i += 1
        if i > count then return nil end
        return items[((start - 1 + i - 1) % capacity) + 1]
    end
end

function lib.ringbuffer:__pairs()
    return self:each(), nil, nil
end

lib.ringbuffer.__len = lib.ringbuffer.size

---@return Array oldestFirst
function lib.ringbuffer:toArray()
    return lib.array:from(self:each())
end

return lib.ringbuffer
