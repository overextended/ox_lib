---@class oxstring : stringlib
lib.string = string

local StringCharset = {}
local NumberCharset = {}

for i = 48, 57 do NumberCharset[#NumberCharset + 1] = string.char(i) end
for i = 65, 90 do StringCharset[#StringCharset + 1] = string.char(i) end
for i = 97, 122 do StringCharset[#StringCharset + 1] = string.char(i) end

---Takes a number of characters and returns a random string.
---@param length number
---@return string
function string.randomString(length)
    if length <= 0 then return '' end
    return string.randomString(length - 1) .. StringCharset[math.random(1, #StringCharset)]
end

---Takes a string and a delimiter and returns the splitted string.
---@param input string
---@param delimiter string
---@return table
function string.splitString(input, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(input, delimiter, from)
    while delim_from do
        result[#result+1] = string.sub(input, from, delim_from - 1)
        from = delim_to + 1
        delim_from, delim_to = string.find(input, delimiter, from)
    end
    result[#result+1] = string.sub(input, from)
    return result
end

---Takes a string and returns the string without the spaces at the beginning and the end.
---@param value string
---@return string?
function string.trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

---Takes a string and returns the string with the  first character as uppercase.
---@param value string
---@return string?
function string.firstToUpper(value)
    if not value then return nil end
    return (string.gsub(value, '^%l', string.upper))
end

return lib.string
