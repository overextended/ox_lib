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
        local n = parseNumber(s, min, max, round and (round == true or i < round))

        i += 1
        arr[i] = n
    end

    return table.unpack(arr)
end

---Tries to convert its argument to a vector.
---@param input string | table
---@param min? number
---@param max? number
---@param round? boolean | number If round is a number, only round n values.
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

---Tries to convert a surface Normal to a Rotation.
---@param input vector3
---@return vector3
function math.normaltorotation(input)
    local inputType = type(input)

    if inputType == 'vector3' then
        local pitch = -math.asin(input.y) * (180.0 / math.pi)
        local yaw = math.atan(input.x, input.z) * (180.0 / math.pi)
        return vec3(pitch, yaw, 0.0)
    end

    error(('cannot convert type %s to a rotation vector'):format(inputType), 2)
end

---Tries to convert its argument to a vector4.
---@param input string | table
---@return vector4
function math.torgba(input)
    local res = math.tovector(input, 0, 255, 3)
    assert(type(res) == 'vector4', 'cannot convert input to rgba')
    parseNumber(res.a, 0, 1)
    return res
end

---Takes a hexidecimal string and returns three integers.
---@param input string
---@return integer
---@return integer
---@return integer
function math.hextorgb(input)
    local r, g, b = string.match(input, '([^#]+.)(..)(..)')
    return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
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
    local left, num, right = string.match(number, '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1' .. (seperator or ',')):reverse()) .. right
end

---Clamp a number between 2 other numbers
---@param val number
---@param lower number
---@param upper number
---@return number
function math.clamp(val, lower, upper)                    -- credit https://love2d.org/forums/viewtopic.php?t=1856
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

---Calculates an intermediate value between `start` and `finish` based on the interpolation `factor`.
---@generic T : number | vector2 | vector3 | vector4
---@param start T
---@param finish T
---@param factor integer The interpolation factor between 0 and 1.
---@return T
function math.interp(start, finish, factor)
    return start + (finish - start) * factor
end

local function interpolateTable(start, finish, factor)
    local interp = math.interp
    local result = {}

    for k, v in pairs(start) do
        result[k] = interp(v, finish[k], factor)
    end

    return result
end

---Linearly interpolates between two values over a specified duration, returning an iterator function that will run once per game-frame.
---@generic T : number | table | vector2 | vector3 | vector4
---@param start T -- The starting value of the interpolation.
---@param finish T -- The ending value of the interpolation.
---@param duration number -- The duration over which to interpolate over in milliseconds.
---@return fun(): T, number
function math.lerp(start, finish, duration)
    local startTime = GetGameTimer()
    local typeStart = type(start)
    local typeFinish = type(finish)

    if typeStart ~= 'number' and typeStart ~= 'vector2' and typeStart ~= 'vector3' and typeStart ~= 'vector4' and typeStart ~= 'table' then
        error(("expected argument 1 to have type '%s' (received %s)"):format('number | table | vector2 | vector3 | vector4', typeStart))
    end

    assert(typeFinish == typeStart, ("expected argument 2 to have type '%s' (received %s)"):format(typeStart, typeFinish))

    local interpFn = typeStart == 'table' and interpolateTable or math.interp
    local step

    return function()
        if not step then
            step = 0
            return start, step
        end

        if step == 1 then return end

        Wait(0)
        step = math.min((GetGameTimer() - startTime) / duration, 1)

        if step < 1 then
            return interpFn(start, finish, step), step
        end

        return finish, step
    end
end

---Rounds a number to a whole number or to the specified number of decimal places.
---@param value number | string
---@param places? number | string
---@return number
function math.round(value, places)
    if type(value) == 'string' then value = tonumber(value) end
    if type(value) ~= 'number' then error('Value must be a number') end

    if places then
        if type(places) == 'string' then places = tonumber(places) end
        if type(places) ~= 'number' then error('Places must be a number') end

        if places > 0 then
            local mult = 10 ^ (places or 0)
            return math.floor(value * mult + 0.5) / mult
        end
    end

    return math.floor(value + 0.5)
end

return lib.math
