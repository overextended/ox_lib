--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local _registerCommand = RegisterCommand

---@param commandName string
---@param callback fun(source, args, raw)
---@param restricted boolean?
function RegisterCommand(commandName, callback, restricted)
    _registerCommand(commandName, function(source, args, raw)
        if not restricted or lib.callback.await('ox_lib:checkPlayerAce', 100, ('command.%s'):format(commandName)) then
            callback(source, args, raw)
        end
    end)
end

RegisterNUICallback('getConfig', function(_, cb)
    cb({
        primaryColor = GetConvar('ox:primaryColor', 'blue'),
        primaryShade = GetConvarInt('ox:primaryShade', 8)
    })
end)

local function isSpawned() return not NetworkIsInTutorialSession() and true or nil end

local function getEntityFromStateBagName(bag)
    local entity = GetEntityFromStateBagName(bag)

    if entity ~= 0 then return entity end
end

local function hasEntityGotCollision(entity)
    return not IsEntityWaitingForWorldCollision(entity) and true or nil
end

AddStateBagChangeHandler('ox_entity_setonground', '', function(bag, value)
    if not value then return end

    lib.waitFor(isSpawned, nil, false)

    local handle = lib.waitFor(getEntityFromStateBagName, 'failed to get entity from statebag', 10000)

    lib.waitFor(hasEntityGotCollision)

    if NetworkGetEntityOwner(handle) ~= cache.playerId then return end

    local entity = IsEntityAVehicle(handle) and lib.vehicle:new(handle) or lib.object:new(handle)

    entity:setOnGround()
    entity:set(bag, true, true)
end)
