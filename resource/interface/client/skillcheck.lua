--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@type promise?
local skillcheck

---@alias SkillCheckDifficulity 'easy' | 'medium' | 'hard' | { areaSize: number, speedMultiplier: number }

---@param difficulty SkillCheckDifficulity | SkillCheckDifficulity[]
---@param inputs string[]?
---@return boolean?
function lib.skillCheck(difficulty, inputs)
    if skillcheck then return end
    skillcheck = promise:new()

    lib.setNuiFocus(false, true)
    SendNUIMessage({
        action = 'startSkillCheck',
        data = {
            difficulty = difficulty,
            inputs = inputs
        }
    })

    return Citizen.Await(skillcheck)
end

function lib.cancelSkillCheck()
    if not skillcheck then
        error('No skillCheck is active')
    end

    SendNUIMessage({action = 'skillCheckCancel'})
end

---@return boolean
function lib.skillCheckActive()
    return skillcheck ~= nil
end

RegisterNUICallback('skillCheckOver', function(success, cb)
    cb(1)

    if skillcheck then
        lib.resetNuiFocus()

        skillcheck:resolve(success)
        skillcheck = nil
    end
end)
