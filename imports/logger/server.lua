local service = GetConvar('ox:logger', 'datadog')
local hostname = GetConvar('sv_projectName', 'fxserver')
local buffer
local bufferSize = 0

local function badResponse(endpoint, response)
    print(('unable to submit logs to %s\n%s'):format(endpoint, json.encode(response, { indent = true })))
end

-- idk where to put this?

local function split(str,pat)
    local tbl = {}
    str:gsub(pat, function(x) tbl[#tbl+1]=x end)
    return tbl
end

local playerData = {}

AddEventHandler('playerDropped', function()
    playerData[source] = nil
end)

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
                ddtags = formatTags(source, ... and string.strjoin(',', string.tostringall(...)) or nil),
            }
        end
    end
end

if service == 'loki' then
    local lokiUser = GetConvar('loki:user', '')
    local lokiKey = GetConvar('loki:key', '')
    local endpoint = ('https://%s:%s@%s/loki/api/v1/push'):format(lokiUser, lokiKey, GetConvar('loki:endpoint', ''))

    -- Converts a string of comma seperated kvp string to a table of kvps
    -- example `discord:blahblah,fivem:blahblah,license:blahblah` -> `{discord="blahblah",fivem="blahblah",license="blahblah"}`
    local function convertDDTagsToKVP(tags)
        local tempTable = { string.strsplit(',', tags) } -- outputs a number index table wth k:v strings as values
        local bTable = table.create(0, #tempTable) -- buffer table

        -- Loop through table and grab only values
        for _, v in pairs(tempTable) do
            local key, value = string.strsplit(':', v) -- splits string on ':' character
            bTable[key] = value
        end

        return bTable -- Return the new table of kvps
    end

    function lib.logger(source, event, message, ...)
        if not buffer then
            buffer = {}

            SetTimeout(500, function()
                -- Strip string keys from buffer
                local tempBuffer = {}
                for _,v in pairs(buffer) do
                    tempBuffer[#tempBuffer+1] = v
                end

                local postBody = json.encode({streams = tempBuffer})
                PerformHttpRequest(endpoint, function(status, _, _, _)
                    if status ~= 204 then
                        badResponse(endpoint, ("Error Code: %s\n%s"):format(status, postBody))
                    end
                end, 'POST', postBody, {
                    ['Content-Type'] = 'application/json',
                })

                buffer = nil
            end)
        end

        -- Generates a nanosecond unix timestamp
        local timestamp = ('%s000000000'):format(os.time(os.date('*t')))

        -- Initializes values table with the message
        local values = {message = message}

        -- Format the args into strings
        local tags = formatTags(source, ... and string.strjoin(',', string.tostringall(...)) or {})
        local tagsTable = convertDDTagsToKVP(tags)

        -- Concatenates tags kvp table to the values table
        for k,v in pairs(tagsTable) do
            values[k] = v -- Store the tags in the values table ready for logging
        end

        -- initialise stream payload
        local payload = {
            stream = {
                hostname = cache.resource,
                service = event
            },
            values = {
                {
                    timestamp,
                    json.encode(values)
                }
            }
        }

        -- Safety check incase it throws index issue
        if not buffer then
            buffer = {}
        end

        -- Checks if the event exists in the buffer and adds to the values if found
        -- else initialises the stream
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
	end
end

return lib.logger
