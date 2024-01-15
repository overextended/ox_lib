local service = GetConvar('ox:logger', 'datadog')
local buffer
local bufferSize = 0

local function removeColorCodes(str)
    -- replace ^[0-9] with nothing
    str = string.gsub(str, "%^%d", "")

    -- replace ^#[0-9A-F]{3,6} with nothing
    str = string.gsub(str, "%^#[%dA-Fa-f]+", "")

    -- replace ~[a-z]~ with nothing
    str = string.gsub(str, "~[%a]~", "")

    return str
end

local hostname = removeColorCodes(GetConvar('ox:logger:hostname', GetConvar('sv_projectName', 'fxserver')))

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
    end) .. ({"", "==", "="})[#data % 3 + 1])
end

local function getAuthorizationHeader(user, password)
    return "Basic " .. base64encode(user .. ":" .. password)
end


local function badResponse(endpoint, status, response)
    warn(('unable to submit logs to %s (status: %s)\n%s'):format(endpoint, status, json.encode(response, { indent = true })))
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
                            if type(response) == 'string' then
                                response = json.decode(response:sub(10)) or response
                                badResponse(endpoint, status, type(response) == 'table' and response.errors[1] or response)
                            end
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

    local endpoint = ('%s/loki/api/v1/push'):format(lokiEndpoint)

    -- Converts a string of comma seperated kvp string to a table of kvps
    -- example `discord:blahblah,fivem:blahblah,license:blahblah` -> `{discord="blahblah",fivem="blahblah",license="blahblah"}`
    local function convertDDTagsToKVP(tags)
        if not tags or type(tags) ~= 'string' then
            return {}
        end
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
                        badResponse(endpoint, status, ("%s"):format(status, postBody))
                    end
                end, 'POST', postBody, headers)

                buffer = nil
            end)
        end

        -- Generates a nanosecond unix timestamp
        ---@diagnostic disable-next-line: param-type-mismatch
        local timestamp = ('%s000000000'):format(os.time(os.date('*t')))

        -- Initializes values table with the message
        local values = {message = message}

        -- Format the args into strings
        local tags = formatTags(source, ... and string.strjoin(',', string.tostringall(...)) or nil)
        local tagsTable = convertDDTagsToKVP(tags)

        -- Concatenates tags kvp table to the values table
        for k,v in pairs(tagsTable) do
            values[k] = v -- Store the tags in the values table ready for logging
        end

        -- initialise stream payload
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
