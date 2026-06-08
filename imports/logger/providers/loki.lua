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
    local lokiUser = GetConvar('loki:user', '')
    local lokiPassword = GetConvar('loki:password', GetConvar('loki:key', ''))
    local lokiEndpoint = GetConvar('loki:endpoint', '')
    local lokiTenant = GetConvar('loki:tenant', '')
    local startingPattern = '^http[s]?://'
    local headers = {
        ['Content-Type'] = 'application/json'
    }

    if lokiUser ~= '' then
        headers['Authorization'] = getAuthorizationHeader(lokiUser, lokiPassword)
    end

    if lokiTenant ~= '' then
        headers['X-Scope-OrgID'] = lokiTenant
    end

    if not lokiEndpoint:find(startingPattern) then
        lokiEndpoint = 'https://' .. lokiEndpoint
    end

    local hostname = ctx.hostname
    local formatTags = ctx.formatTags

    return {
        endpoint = ('%s/loki/api/v1/push'):format(lokiEndpoint),
        headers = headers,
        okStatus = 204,

        append = function(buffer, source, event, message, ...)
            ---@diagnostic disable-next-line: param-type-mismatch
            local timestamp = ('%s000000000'):format(os.time(os.date('*t')))

            local values = { message = message }

            local playerIdentifierTags = formatTags(source, nil)
            if playerIdentifierTags and type(playerIdentifierTags) == 'string' then
                local tempTable = { string.strsplit(',', playerIdentifierTags) }
                for _, v in pairs(tempTable) do
                    local key, value = string.strsplit(':', v)
                    values[key] = value
                end
            end

            local args = { ... }
            for _, arg in pairs(args) do
                if type(arg) == 'table' then
                    for tagKey, tagValue in pairs(arg) do
                        values[tagKey] = tagValue
                    end
                elseif type(arg) == 'string' then
                    local tempTable = { string.strsplit(',', arg) }

                    for _, v in pairs(tempTable) do
                        local tagKey, tagValue = string.strsplit(':', v)

                        if tagKey and tagValue then
                            values[tagKey] = tagValue
                        else
                            lib.print.warn(('Invalid tag format for argument "%s" in event "%s"'):format(v, event))
                        end
                    end
                end
            end

            local payload = {
                stream = {
                    server = hostname,
                    resource = cache.resource,
                    event = event
                },
                values = {
                    {
                        timestamp,
                        json.encode(values)
                    }
                }
            }

            if not buffer then
                buffer = {}
            end

            if not buffer[event] then
                buffer[event] = payload
            else
                local lastIndex = #buffer[event].values
                lastIndex += 1

                buffer[event].values[lastIndex] = {
                    timestamp,
                    json.encode(values)
                }
            end
        end,

        encode = function(buffer)
            local tempBuffer = {}
            for _, v in pairs(buffer) do
                tempBuffer[#tempBuffer + 1] = v
            end

            return json.encode({ streams = tempBuffer })
        end,

        parseError = function(status, _, body)
            return ("%s"):format(status, body)
        end,
    }
end
