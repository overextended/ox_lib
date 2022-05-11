if not lib.player then lib.player() end

return function(resource)
	local ESX = exports[resource]:getSharedObject()

	RegisterNetEvent('esx:playerLoaded', function(xPlayer)
		ESX.PlayerData = xPlayer
	end)

	RegisterNetEvent('esx:setJob', function(job)
		ESX.PlayerData.job = job
	end)

	lib.addPlayerMethod('hasGroup', function(self, filter)
		local type = type(filter)

		if type == 'string' then
			return ESX.PlayerData.job.name == filter
		end

		local tabletype = table.type(filter)

		if tabletype == 'hash' then
			local grade = filter[ESX.PlayerData.job.name]
			return grade and grade <= ESX.PlayerData.job.grade
		end

		if tabletype == 'array' then
			for i = 1, #filter do
				if ESX.PlayerData.job.name == filter[i] then
					return true
				end
			end

			return false
		end
	end)

	return ESX
end
