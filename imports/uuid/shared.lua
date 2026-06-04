lib.uuid = {}

local UUID = table.concat({
    ('%02x'):rep(4),
    ('%02x'):rep(2),
    ('%02x'):rep(2),
    ('%02x'):rep(2),
    ('%02x'):rep(6),
}, '-')

---Generates a UUID v7 string.
---@return string
function lib.uuid.generate()
    local timestamp = (os and os.time() or GetCloudTimeAsInt()) * 1000
    local bytes = table.create(16, 0)

    for i = 1, 6 do
        bytes[i] = (timestamp >> (40 - (i - 1) * 8)) & 0xFF
    end

    for i = 7, 16 do
        bytes[i] = math.random(0, 255)
    end

    bytes[7] = (bytes[7] & 0x0F) | 0x70
    bytes[9] = (bytes[9] & 0x3F) | 0x80

    return UUID:format(table.unpack(bytes))
end

---Checks if a string is a valid UUID v7.
---@param str string
---@return boolean
function lib.uuid.validate(str)
    if type(str) ~= 'string' or #str ~= 36 or not str:match('^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$') then
        return false
    end

    local version = tonumber(str:sub(15, 15), 16)
    local variant = tonumber(str:sub(20, 20), 16)

    return version == 7 and (variant & 0x8) == 0x8
end

return lib.uuid
