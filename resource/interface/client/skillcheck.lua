---@type promise?
local skillcheck

---@alias SkillCheckDifficulity 'easy' | 'medium' | 'hard' | { areaSize: number, speedMultiplier: number }

---@param difficulty SkillCheckDifficulity | SkillCheckDifficulity[]
---@return boolean?
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

RegisterNUICallback('skillCheckOver', function(success, cb)
    cb(1)
    if skillcheck then
        skillcheck:resolve(success)
        skillcheck = nil
        SetNuiFocus(false, false)
    end
end)
