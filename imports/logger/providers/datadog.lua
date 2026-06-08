--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@param ctx LogContext
---@return LogProvider?
return function(ctx)
    local key = GetConvar('datadog:key', ''):gsub("[\'\"]", '')
    if key == '' then return end

    local hostname = ctx.hostname
    local formatTags = ctx.formatTags

    return {
        endpoint = ('https://http-intake.logs.%s/api/v2/logs'):format(GetConvar('datadog:site', 'datadoghq.com')),
        headers = {
            ['Content-Type'] = 'application/json',
            ['DD-API-KEY'] = key,
        },
        okStatus = 202,
        encode = json.encode,

        append = function(buffer, source, event, message, ...)
            buffer[#buffer + 1] = {
                hostname = hostname,
                service = event,
                message = message,
                resource = cache.resource,
                ddsource = tostring(source),
                ddtags = formatTags(source, ... and string.strjoin(',', string.tostringall(...)) or nil),
            }
        end,

        parseError = function(_, response)
            if type(response) ~= 'string' then return nil end
            response = json.decode(response:sub(10)) or response
            return type(response) == 'table' and response.errors[1] or response
        end,
    }
end
