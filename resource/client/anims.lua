function PlayAnim(wait, dict, name, introSpeed, outroSpeed, duration, flag, pbRate, lockX, lockY, lockZ)
    local playerPed = PlayerPedId()
    if not lockX then lockX = 0 end
    if not lockY then lockY = 0 end
    if not lockZ then lockZ = 0 end
    RequestAnimDict(dict)
    Citizen.CreateThread(function()    
        while not HasAnimDictLoaded(dict) do Wait(0) end
        TaskPlayAnim(playerPed, dict, name, introSpeed, outroSpeed, duration, flag, pbRate, lockX, lockY, lockZ)
        Wait(wait)
        if wait > 0 then ClearPedSecondaryTask(playerPed) end
        RemoveAnimDict(dict)
    end)
end

function PlayAnimAdvanced(wait, dict, name, posX, posY, posZ, rotX, rotY, rotZ, introSpeed, outroSpeed, duration, flag, time)
    local playerPed = PlayerPedId()
	RequestAnimDict(dict)
	CreateThread(function()
		while not HasAnimDictLoaded(dict) do Wait(0) end
		TaskPlayAnimAdvanced(playerPed, dict, name, posX, posY, posZ, rotX, rotY, rotZ, introSpeed, outroSpeed, duration, flag, time, 0, 0)
		Wait(wait)
		if wait > 0 then ClearPedSecondaryTask(playerPed) end
		RemoveAnimDict(dict)
	end)
end

exports('PlayAnim', PlayAnim)
exports('PlayAnimAdvanced', PlayAnimAdvanced)