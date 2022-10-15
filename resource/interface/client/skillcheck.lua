---@type promise?
local skillcheck
local gameCount = 0

---@alias SkillCheckDifficulity 'easy' | 'medium' | 'hard' | { areaSize: number, speedMultiplier: number }

---@type SkillCheckDifficulity | SkillCheckDifficulity[]
local gameDifficulty

---@type promise?
local gamePromise

local function resolveSkillCheck(success)
    if skillcheck then
        skillcheck:resolve(success)
        skillcheck = nil
        SetNuiFocus(false, false)
    end
end

---@param difficulty SkillCheckDifficulity | SkillCheckDifficulity[]
---@return boolean?
function lib.skillCheck(difficulty)
    if skillcheck then return end

    skillcheck = promise:new()
    gameDifficulty = difficulty
    SetNuiFocus(true, false)

    if type(difficulty) == 'table' then
        gameCount = 0
        for i = 1, #difficulty do
            gamePromise = promise:new()
            SendNUIMessage({
                action = 'startSkillCheck',
                data = difficulty[i]
            })
            if not Citizen.Await(gamePromise) then
                gamePromise = nil
                break
            end
        end
    else
        SendNUIMessage({
            action = 'startSkillCheck',
            data = difficulty
        })
    end

    return Citizen.Await(skillcheck)
end

RegisterNUICallback('skillCheckOver', function(data, cb)
    cb(1)
    if not gamePromise then return resolveSkillCheck(data.success) end
    gamePromise:resolve(data.success)
    if not data.success then return resolveSkillCheck(data.success) end
    gameCount += 1
    if gameCount == #gameDifficulty then
        resolveSkillCheck(data.success)
    end
end)
