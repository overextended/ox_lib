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

---Capitalizes the first lowercase letter of a string
---@param str string
---@return string
function string.capitalize(str)
    return str:gsub('^%l', string.upper)
end

---Checks if a string starts with a given prefix
---@param str string
---@param prefix string
---@return boolean
function string.startsWith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

---Checks if a string ends with a given suffix
---@param str string
---@param suffix string
---@return boolean
function string.endsWith(str, suffix)
    return suffix == '' or str:sub(-#suffix) == suffix
end

---Checks if a string contains a given value
---@param str string
---@param value string
---@param plain? boolean If true or nil, searches as plain text. If false, searches as Lua pattern.
---@return boolean
function string.contains(str, value, plain)
    return str:find(value, 1, plain ~= false) ~= nil
end

---Checks if a string is empty
---@param str string
---@return boolean
function string.isEmpty(str)
    return str == ''
end

---Checks if a string is blank (empty or only whitespace)
---@param str string
---@return boolean
function string.isBlank(str)
    return str:match('^%s*$') ~= nil
end

---Escapes Lua pattern characters in a string
---@param str string
---@return string
function string.escapePattern(str)
    return str:gsub('([^%w])', '%%%1')
end

---Replaces all text or pattern matches in a string
---@param str string
---@param old string
---@param new string
---@param plain? boolean If true or nil, replaces plain text. If false, replaces Lua pattern matches.
---@return string
function string.replace(str, old, new, plain)
    if plain ~= false then
        old = string.escapePattern(old)
        new = new:gsub('%%', '%%%%')
    end

    return str:gsub(old, new)
end

return lib.string
