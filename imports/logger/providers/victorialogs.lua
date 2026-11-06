--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64encode(data)
    return ((data:gsub(".", function(x)
        local r, b = "", x:byte()
        for i = 8, 1, -1 do
            r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
        end
        return r;
    end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
        if (#x < 6) then
            return ""
        end
        local c = 0
        for i = 1, 6 do
            c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
        end
        return b:sub(c + 1, c + 1)
    end) .. ({ "", "==", "=" })[#data % 3 + 1])
end

local function getAuthorizationHeader(user, password)
    return "Basic " .. base64encode(user .. ":" .. password)
end

---@param ctx LogContext
---@return LogProvider?
return function(ctx)
    local victoriaUser = GetConvar('victorialogs:user', '')
    local victoriaPassword = GetConvar('victorialogs:password', '')
    local victoriaEndpoint = GetConvar('victorialogs:endpoint', '')
    local includeServer = GetConvarInt('victorialogs:includeserver', 1) == 1

    if not victoriaEndpoint:find('^https?://') then
        victoriaEndpoint = 'http://' .. victoriaEndpoint
    end

    local headers = {
        ['Content-Type'] = 'application/stream+json',
        ['VL-Stream-Fields'] = includeServer and 'resource,server' or 'resource',
    }

    if victoriaUser ~= '' then
        headers['Authorization'] = getAuthorizationHeader(victoriaUser, victoriaPassword)
    end

    local formatTags = ctx.formatTags
    local hostname = ctx.hostname

    return {
        endpoint = victoriaEndpoint .. '/insert/jsonline',
        headers = headers,
        okStatus = 200,

        append = function(buffer, source, event, message, ...)
            local fields = {}

            local playerTags = formatTags(source, nil)
            if playerTags and type(playerTags) == 'string' then
                local tempTable = { string.strsplit(',', playerTags) }
                for _, tag in pairs(tempTable) do
                    local key, value = string.strsplit(':', tag, 2)
                    if key and value then
                        fields[key] = value
                    end
                end
            end

            local args = { ... }
            for _, arg in pairs(args) do
                if type(arg) == 'table' then
                    for key, value in pairs(arg) do
                        fields[key] = value
                    end
                elseif type(arg) == 'string' then
                    local tempTable = { string.strsplit(',', arg) }
                    for _, tag in pairs(tempTable) do
                        local key, value = string.strsplit(':', tag, 2)
                        if key and value then
                            fields[key] = value
                        elseif type(fields.tags) == 'string' then
                            fields.tags = fields.tags .. ',' .. tag
                        else
                            fields.tags = tag
                        end
                    end
                elseif type(arg) == 'number' or type(arg) == 'boolean' then
                    local tag = tostring(arg)
                    if type(fields.tags) == 'string' then
                        fields.tags = fields.tags .. ',' .. tag
                    else
                        fields.tags = tag
                    end
                end
            end

            fields._time = os.time()
            fields.server = hostname
            fields.resource = cache.resource
            fields.event = event
            fields.source = source
            fields._msg = message

            buffer[#buffer + 1] = json.encode(fields)
        end,

        encode = function(buffer)
            return table.concat(buffer, '\n')
        end,

        parseError = function(_, response, body)
            return response or body
        end,
    }
end
