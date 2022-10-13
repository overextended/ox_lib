local skillcheck

function lib.skillCheck(difficulty)
    if skillcheck then return end
    skillcheck = promise:new()
    SetNuiFocus(true, false)
    SendNUIMessage({
        action = 'startSkillCheck',
        data = difficulty
    })
    return Citizen.Await(skillcheck)
end

RegisterNUICallback('skillCheckOver', function(data, cb)
    cb(1)
    skillcheck:resolve(data.success)
    skillcheck = nil
    SetNuiFocus(false, false)
end)