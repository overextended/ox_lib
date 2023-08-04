---@class oxmath : mathlib
lib.math = math

local function parseNumber(input, min, max, round)
    local n = tonumber(input)

    if not n then
        error(("value cannot be converted into a number (received %s)"):format(input), 3)
    end

    n = round and math.floor(n + 0.5) or n

    if min and n < min then
        error(("value does not meet minimum value of '%s' (received %s)"):format(min, n), 3)
    end

    if max and n > max then
        error(("value exceeds maximum value of '%s' (received %s)"):format(max, n), 3)
    end

    return n
end

---Takes a string and returns a set of scalar values.
---@param input string
---@param min? number
---@param max? number
---@param round? boolean
---@return number? ...
function math.toscalars(input, min, max, round)
    local arr = {}
    local i = 0

    for s in string.gmatch(input:gsub('[%w]+%w?%(', ''), '(-?[%w.%w]+)') do
        local n = parseNumber(s, min, max, round)

        i += 1
        arr[i] = n
    end

    return table.unpack(arr)
end

---Tries to convert its argument to a vector.
---@param input string | table
---@param min? number
---@param max? number
---@param round? boolean
---@return number | vector2 | vector3 | vector4
function math.tovector(input, min, max, round)
    local inputType = type(input)

    if inputType == 'string' then
        ---@diagnostic disable-next-line: param-type-mismatch
        return vector(math.toscalars(input, min, max, round))
    end

    if inputType == 'table' then
        for _, v in pairs(input) do
            parseNumber(v, min, max, round)
        end

        if table.type(input) == 'array' then
            return vector(table.unpack(input))
        end

        -- vector doesn't accept literal nils
        return input.w and vector4(input.x, input.y, input.z, input.w)
            or input.z and vector3(input.x, input.y, input.z)
            or input.y and vector2(input.x, input.y)
            or input.x + 0.0
    end

    error(('cannot convert %s to a vector value'):format(inputType), 2)
end

---Tries to convert its argument to a vector.
---@param input string | table
---@return number | vector2 | vector3 | vector4
function math.torgba(input)
    return math.tovector(input, 0, 255, true)
end

---Formats a number as a hexadecimal string.
---@param n number | string
---@param upper? boolean
---@return string
function math.tohex(n, upper)
    local formatString = ('0x%s'):format(upper and '%X' or '%x')
    return formatString:format(n)
end

---Converts input number into grouped digits
---@param number number
---@param seperator? string
---@return string
function math.groupdigits(number, seperator) -- credit http://richard.warburton.it
    local left,num,right = string.match(number,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1' .. (seperator or ',')):reverse())..right
end

return lib.math
