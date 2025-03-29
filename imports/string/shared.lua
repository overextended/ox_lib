--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class oxstring : stringlib
lib.string = string

local string_char = string.char
local math_random = math.random

local function getLetter() return string_char(math_random(65, 90)) end
local function getLowerLetter() return string_char(math_random(97, 122)) end
local function getInt() return math_random(0, 9) end
local function getAlphanumeric() return math_random(0, 1) == 1 and getLetter() or getInt() end

local formatChar = {
    ['1'] = getInt,
    ['A'] = getLetter,
    ['a'] = getLowerLetter,
    ['.'] = getAlphanumeric,
}

---Creates a random string based on a given pattern.
---`1` will output a random number from 0-9.
---`A` will output a random letter from A-Z.
---`a` will output a random letter from a-z.
---`.` will output a random letter or number.
---`^` will output the following character literally.
---Any other character will output said character.
---@param pattern string
---@param length? integer Sets the length of the returned string, either padding it or omitting characters.
---@return string
function string.random(pattern, length)
    local len = length or #pattern:gsub('%^', '')
    local arr = table.create(len, 0)
    local size = 0
    local i = 0

    while size < len do
        i += 1
        ---@type string | integer
        local char = pattern:sub(i, i)

        if char == '' then
            arr[size + 1] = string.rep(' ', len - size)
            break
        elseif char == '^' then
            i += 1
            char = pattern:sub(i, i)
        else
            local fn = formatChar[char]
            char = fn and fn() or char
        end

        size += 1
        arr[size] = char
    end

    return table.concat(arr)
end

return lib.string
