--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@param ctx LogContext
---@return LogProvider?
return function(ctx)
    local key = GetConvar('fivemanage:key', '')
    if key == '' then return end

    local hostname = ctx.hostname
    local formatTags = ctx.formatTags

    local headers = {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = key,
        ['User-Agent'] = 'ox_lib',
    }

    local dataset = GetConvar('fivemanage:dataset', '')
    if dataset ~= '' then
        headers['X-Fivemanage-Dataset'] = dataset
    end

    return {
        endpoint = 'https://api.fivemanage.com/api/logs/batch',
        headers = headers,
        okStatus = 200,
        encode = json.encode,

        append = function(buffer, source, event, message, ...)
            local metadata = {
                hostname = hostname,
                service = event,
                source = source,
            }

            local playerTags = formatTags(source, nil)
            if playerTags and type(playerTags) == 'string' then
                local tempTable = { string.strsplit(',', playerTags) }
                for _, v in pairs(tempTable) do
                    local k, vv = string.strsplit(':', v)
                    if k and vv then
                        metadata[k] = vv
                    end
                end
            end

            local args = { ... }
            for _, arg in pairs(args) do
                if type(arg) == 'table' then
                    for k, v in pairs(arg) do
                        metadata[k] = v
                    end
                elseif type(arg) == 'string' then
                    local k, v = string.strsplit(':', arg)
                    if k and v then
                        metadata[k] = v
                    end
                end
            end

            buffer[#buffer + 1] = {
                level = 'info',
                message = message,
                resource = cache.resource,
                metadata = metadata,
            }
        end,

        parseError = function(_, response)
            if type(response) ~= 'string' then return nil end
            return json.decode(response) or response
        end,
    }
end
