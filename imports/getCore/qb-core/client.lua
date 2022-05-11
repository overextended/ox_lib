if not lib.player then lib.player() end

return function(resource)
	local QBCore = exports[resource]:GetCoreObject()
	local PlayerData

	RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
		PlayerData = QBCore.Functions.GetPlayerData()
	end)

	RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
		PlayerData.job = job
	end)

	RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
		PlayerData.gang = gang
	end)

	lib.addPlayerMethod('hasGroup', function(self, filter)
		local type = type(filter)

		if type == 'string' then
			return PlayerData.job.name == filter or PlayerData.gang.name == filter
		end

		local tabletype = table.type(filter)

		if tabletype == 'hash' then
			local jobGrade = filter[PlayerData.job.name]

			if jobGrade then
				return jobGrade <= PlayerData.job.grade
			end

			local gangGrade = filter[PlayerData.gang.name]

			if gangGrade then
				return gangGrade <= PlayerData.gang.grade
			end

			return false
		end

		if tabletype == 'array' then
			for i = 1, #filter do
				local group = filter[i]

				if PlayerData.job.name == group or PlayerData.gang.name == group then
					return true
				end
			end

			return false
		end
	end)

	return QBCore
end
