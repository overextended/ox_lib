local service = GetConvar('ox:logger', 'datadog')
local hostname = GetConvar('sv_projectName', 'fxserver')
local buffer
local bufferSize = 0

local function badResponse(endpoint, response)
    print(('unable to submit logs to %s\n%s'):format(endpoint, json.encode(response, { indent = true })))
end

local playerData = {}

AddEventHandler('playerDropped', function()
    playerData[source] = nil
end)

if service == 'datadog' then
    local key = GetConvar('datadog:key', ''):gsub("[\'\"]", '')

    if key ~= '' then
        local endpoint = ('https://http-intake.logs.%s/api/v2/logs'):format(GetConvar('datadog:site', 'datadoghq.com'))

        local headers = {
            ['Content-Type'] = 'application/json',
            ['DD-API-KEY'] = key,
        }

        local function formatTags(source, tags)
            if type(source) == 'number' and source > 0 then
                local data = playerData[source]

                if not data then
                    local _data = {
                        ('username:%s'):format(GetPlayerName(source))
                    }

                    local num = 1

                    ---@cast source string
                    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
                        local identifier = GetPlayerIdentifier(source, i)

                        if not identifier:find('ip') then
                            num += 1
                            _data[num] = identifier
                        end
                    end

                    data = table.concat(_data, ',')
                    playerData[source] = data
                end

                tags = tags and ('%s,%s'):format(tags, data) or data
            end

            return tags
        end

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
                ddtags = formatTags(source, ... and string.strjoin(',', string.tostringall(...)) or nil),
            }
        end
    end
end

if service == 'loki' then
    local lokiUser = GetConvar('loki:user', '')
    local lokiKey = GetConvar('loki:key', '')
    local lokiEndpoint = GetConvar('loki:endpoint', '')
    local site = ('https://%s:%s@%s/loki/api/v1/push'):format(lokiUser, lokiKey, lokiEndpoint)
    local resourceName = GetCurrentResourceName()

    function lib.logger(source, event, message, ...)
        local timestamp = ('%s000000000'):format(os.time(os.date('*t')))
        local data = ""
        if type(message) =="string" then
            data = json.encode({
                streams = {
                    {
                        stream = {
                            hostname = resourceName,
                            service = event
                        },
                        values = {
                            timestamp,
                            json.encode({message = message})
                        }
                    }
                }
            })
        elseif type(message) == "table" then
            data = json.encode({
                streams = {
                    {
                        stream = {
                            hostname = resourceName,
                            service = event
                        },
                        values = {
                            timestamp,
                            json.encode(message)
                        }
                    }
                }
            })
        end


        if data == "" then
            print("LOGGER DATA WAS NOT TABLE OR STRING")
            return
        end
		PerformHttpRequest(site, function(status, _, _, response)
			if status ~= 204 then
				-- Thanks, I hate it
				print(('unable to submit logs to %s\n%s'):format(site, json.encode(response, {indent=true})))
			end
		end, 'POST', data, {
			['Content-Type'] = 'application/json',
		})
	end

end

return lib.logger or function() end
