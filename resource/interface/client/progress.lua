local progress
local DisableControlAction = DisableControlAction
local DisablePlayerFiring = DisablePlayerFiring
local disable = {}
local disableKeys = {
	mouse = {1, 2, 106},
	move = {21, 30, 31, 36},
	car = {63, 64, 71, 72, 75},
	combat = {25}
}

local function startProgress(data)
	progress = data

	if data.anim then
		if data.anim.dict then
			lib.requestAnimDict(data.anim.dict)
			TaskPlayAnim(cache.ped, data.anim.dict, data.anim.clip, data.anim.blendIn or 3.0, data.anim.blendOut or 1.0, data.anim.duration or -1, data.anim.flag or 49, data.anim.playbackRate or 0, data.anim.lockX, data.anim.lockY, data.anim.lockZ)
			data.anim = true
		elseif data.anim.scenario then
			TaskStartScenarioInPlace(cache.ped, data.anim.scenario, 0, data.anim.playEnter or true)
			data.anim = true
		end
	end

	if data.prop then
		for i = 1, #data.prop do
			local prop = data.prop[i]

			if prop then
				lib.requestModel(prop.model)

				local coords = GetEntityCoords(cache.ped)
				local object = CreateObject(prop.model, coords.x, coords.y, coords.z, true, true, true)
				AttachEntityToEntity(object, cache.ped, GetPedBoneIndex(cache.ped, prop.bone or 60309), prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, true, true, false, true, 0, true)
				data['prop'..i] = object
			end
		end
	end

	local count

	if data.disable then
		count = 0

		for k, v in pairs(data.disable) do
			if v then
				local keys = disableKeys[k]

				for i = 1, #keys do
					count += 1
					disable[count] = keys[i]
				end
			end
		end
	end

	if count and count > 0 then
		while progress do
			for i = 1, count do
				DisableControlAction(0, disable[i], true)
			end

			if data.disable.combat then
				DisablePlayerFiring(cache.playerId, true)
			end

			Wait(0)
		end
	elseif data.canCancel then
		while progress do Wait(0) end
	else
		Wait(data.duration)
	end

	if data.anim then
		ClearPedTasks(cache.ped)
	end

	if data.prop then
		for i = 1, #data.prop do
			local prop = data['prop'..i]

			if prop then
				DetachEntity(prop)
				DeleteEntity(prop)
			end
		end
	end

	local cancel = progress == false
	table.wipe(disable)
	progress = nil

	if cancel then
		SendNUIMessage({ action = 'progressCancel' })
		return false
	end

	return true
end

function lib.progressBar(data)
	while progress ~= nil do Wait(100) end

	if data.useWhileDead or not IsEntityDead(cache.ped) then
		SendNUIMessage({
			action = 'progress',
			data = {
				label = data.label,
				duration = data.duration
			}
		})

		return startProgress(data)
	end
end

function lib.progressCircle(data)
	while progress ~= nil do Wait(100) end

	if data.useWhileDead or not IsEntityDead(cache.ped) then
		SendNUIMessage({
			action = 'circleProgress',
			data = {
				duration = data.duration,
				position = data.position
			}
		})

		return startProgress(data)
	end
end

function lib.cancelProgress()
	if not progress then
		error('No progress bar is active')
	elseif not progress.canCancel then
		error(("Progress bar '%s' cannot be cancelled"):format(id))
	end

	progress = false
end

RegisterNUICallback('progressComplete', function(data, cb)
	cb(1)
	progress = nil
end)
