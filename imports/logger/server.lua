local key = GetConvar('datadog:key', '')

local lokiUser = GetConvar('loki:user', '')
local lokiKey = GetConvar('loki:key', '')
local lokiEndpoint = GetConvar('loki:endpoint')

if key ~= '' then
	local site = ('https://http-intake.logs.%s/api/v2/logs'):format(GetConvar('datadog:site', 'datadoghq.com'))
	local resourceName = GetCurrentResourceName()
	key = key:gsub("[\'\"]", '')

	function lib.logger(source, event, message, ...)
		local data = json.encode({
			hostname = resourceName,
			service = event,
			message = message,
			ddsource = tostring(source),
			ddtags = string.strjoin(',', string.tostringall(...))
		})

		PerformHttpRequest(site, function(status, _, _, response)
			if status ~= 202 then
				-- Thanks, I hate it
				response = json.decode(response:sub(10)).errors[1]
				print(('unable to submit logs to %s\n%s'):format(site, json.encode(response, {indent=true})))
			end
		end, 'POST', data, {
			['Content-Type'] = 'application/json',
			['DD-API-KEY'] = key
		})
	end
end

if lokiUser ~= '' and lokiKey ~= '' and lokiEndpoint ~= '' then
    local site = ('https://%s:%s@%s/loki/api/v1/push'):format(lokiUser, lokiKey, lokiEndpoint)
    local resourceName = GetCurrentResourceName()

    function lib.logger(source, event, message, ...)
        local timestamp = tostring(os.time(os.date("*t")) ) .. "000000000"
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
			if status ~= 202 then
				-- Thanks, I hate it
				response = json.decode(response:sub(10)).errors[1]
				print(('unable to submit logs to %s\n%s'):format(site, json.encode(response, {indent=true})))
			end
		end, 'POST', data, {
			['Content-Type'] = 'application/json',
		})
	end

end

return lib.logger or function() end
