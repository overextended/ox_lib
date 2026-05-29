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

local playerState = LocalPlayer.state

RegisterNetEvent('ox_lib:setStateBagValue', function(key, value)
    if source == '' then return end

    playerState[key] = value
end)

AddStateBagChangeHandler('ox_entity_setonground', '', function(bag, value)
    if not value then return end

    lib.waitFor(isSpawned, nil, false)

    local handle = lib.waitFor(function()
        local entity = GetEntityFromStateBagName(bag)

        if entity ~= 0 then return entity end

    end, 'failed to get entity from statebag', 10000)

    lib.waitFor(function()
        return not IsEntityWaitingForWorldCollision(handle) and true or nil
    end)

    local entity = IsEntityAVehicle(handle) and lib.vehicle:new(handle) or lib.object:new(handle)

    if IsEntityInAir(handle) then
        local coords = GetEntityCoords(handle)
        local hit, _, dest = lib.raycast.fromCoords(coords, vector3(coords.x, coords.y, coords.z - 1000), 511, 4)

        if hit then
            entity:setCoords(dest.x, dest.y, dest.z + 2)
        else
            local z = GetHeightmapBottomZForPosition(coords.x, coords.y)
            entity:setCoords(coords.x, coords.y, z + 10)
        end
    end

    if entity:setOnGround() then
        if entity:setr('ox_entity_setonground', nil) then return end
    end

    error(('failed to set "%s" on ground'):format(bag))
end)
