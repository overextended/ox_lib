local service = GetConvar('ox:logger', 'datadog')
local hostname = GetConvar('sv_projectName', 'fxserver')
local buffer
local bufferSize = 0

local function badResponse(endpoint, response)
    print(('unable to submit logs to %s\n%s'):format(endpoint, json.encode(response, { indent = true })))
end

if service == 'datadog' then
    local key = GetConvar('datadog:key', ''):gsub("[\'\"]", '')

    if key ~= '' then
        local endpoint = ('https://http-intake.logs.%s/api/v2/logs'):format(GetConvar('datadog:site', 'datadoghq.com'))

        local headers = {
            ['Content-Type'] = 'application/json',
            ['DD-API-KEY'] = key,
        }

        function lib.logger(source, event, message, ...)
            if not buffer then
                buffer = {}

                SetTimeout(500, function()
                    PerformHttpRequest(endpoint, function(status, _, _, response)
                        if status ~= 202 then
                            badResponse(endpoint, json.decode(response:sub(10)).errors[1])
                        end
                    end, 'POST', json.encode(buffer), headers)

                    buffer = nil
                    bufferSize = 0
                end)
            end

            bufferSize += 1
            buffer[bufferSize] = {
                hostname = hostname,
                service = event,
                message = message,
                resource = cache.resource,
                ddsource = tostring(source),
                ddtags = string.strjoin(',', string.tostringall(...))
            }
        end
    end
end

return lib.logger or function() end
