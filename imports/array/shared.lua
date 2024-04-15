---@class Array : OxClass
local Array = lib.class('Array')

function Array:constructor(...)
    local arr = { ... }

    for i = 1, #arr do
        self[i] = arr[i]
    end
end

function Array:__newindex(index, value)
    if type(index) ~= 'number' then error(("Cannot insert non-number index '%s' into an array."):format(index)) end

    rawset(self, index, value)
end

---Create a new array containing the elements from two arrays.
---@param arr Array | any[]
function Array:merge(arr)
    local newArr = table.clone(self)
    local length = #self

    for i = 1, #arr do
        length += 1
        newArr[length] = arr[i]
    end

    return Array:new(table.unpack(newArr))
end

---Tests if all elements in an array succeed in passing the provided test function.
---@param testFn fun(element: unknown): boolean
function Array:every(testFn)
    for i = 1, #self do
        if not testFn(self[i]) then
            return false
        end
    end

    return true
end

---Creates a new array containing the elements from an array thtat pass the test of the provided function.
---@param testFn fun(element: unknown): boolean
function Array:filter(testFn)
    local newArr = {}
    local length = 0

    for i = 1, #self do
        local element = self[i]

        if testFn(element) then
            length += 1
            newArr[length] = element
        end
    end

    return Array:new(table.unpack(newArr))
end

---Returns the first or last element of an array that passes the provided test function.
---@param testFn fun(element: unknown): boolean
---@param last? boolean
function Array:find(testFn, last)
    local a = last and #self or 1
    local b = last and 1 or #self
    local c = last and -1 or 1

    for i = a, b, c do
        local element = self[i]

        if testFn(element) then
            return element
        end
    end
end

---Returns the first or last index of the first element of an array that passes the provided test function.
---@param testFn fun(element: unknown): boolean
---@param last? boolean
function Array:findIndex(testFn, last)
    local a = last and #self or 1
    local b = last and 1 or #self
    local c = last and -1 or 1

    for i = a, b, c do
        local element = self[i]

        if testFn(element) then
            return element
        end
    end
end

---Returns the first or last index of the first element of an array that matches the provided value.
---@param value unknown
---@param last? boolean
function Array:indexOf(value, last)
    local a = last and #self or 1
    local b = last and 1 or #self
    local c = last and -1 or 1

    for i = a, b, c do
        local element = self[i]

        if element == value then
            return element
        end
    end
end

---Executes the provided function for each element in an array.
---@param cb fun(element: unknown)
function Array:forEach(cb)
    for i = 1, #self do
        cb(self[i])
    end
end

---Concatenates all array elements into a string, seperated by commas or the specified seperator.
---@param seperator? string
function Array:join(seperator)
    return table.concat(self, seperator or ',')
end

---Removes the last element from an array and returns the removed element.
function Array:pop()
    return table.remove(self)
end

---Adds the given elements to the end of an array and returns the new array length.
---@param ... any
function Array:push(...)
    local elements = { ... }
    local length = #self

    for i = 1, #elements do
        length += 1
        self[length] = elements[i]
    end

    return length
end

---Removes the first element from an array and returns the removed element.
function Array:shift()
    return table.remove(self, 1)
end

lib.array = Array

return lib.array
