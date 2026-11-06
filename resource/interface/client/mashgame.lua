--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@type promise?
local mashgame

---@class MashGameOptions
---@field decayRate? number Decay rate per second when released (percentage, default: 25)
---@field failOnWrongKey? boolean Fail immediately on incorrect keypress (default: true)
---@field timeout? number | number[] Max duration in milliseconds per stage or overall

---@param durations number | number[] Hold duration in ms for each stage
---@param keys? string | string[] Key or pool of keys to select from per stage (default: {'e'})
---@param options? MashGameOptions Optional game settings
---@return boolean? success
function lib.mashGame(durations, keys, options)
    if mashgame then return end

    if type(durations) == 'number' then
        durations = { durations }
    elseif not durations or #durations == 0 then
        durations = { 3000 }
    end

    if type(keys) == 'string' then
        keys = { keys }
    elseif not keys or #keys == 0 then
        keys = { 'e' }
    end

    options = options or {}

    mashgame = promise:new()

    lib.setNuiFocus(false, true)
    SendNUIMessage({
        action = 'startMashGame',
        data = {
            durations = durations,
            keys = keys,
            decayRate = options.decayRate,
            failOnWrongKey = options.failOnWrongKey,
            timeout = options.timeout
        }
    })

    return Citizen.Await(mashgame)
end

function lib.cancelMashGame()
    if not mashgame then
        error('No mashGame is active')
    end

    SendNUIMessage({ action = 'mashGameCancel' })
end

---@return boolean
function lib.mashGameActive()
    return mashgame ~= nil
end

RegisterNUICallback('mashGameOver', function(success, cb)
    cb(1)

    if mashgame then
        lib.resetNuiFocus()

        mashgame:resolve(success)
        mashgame = nil
    end
end)
