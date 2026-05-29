--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local stateKey = 'ox_lib:setVehicleProperties'

---@param vehicle number
---@param props VehicleProperties
---@diagnostic disable-next-line: duplicate-set-field
function lib.setVehicleProperties(vehicle, props)
    Entity(vehicle).state:set(stateKey, props, true)
end

---@param payload StateHookPayload
---@return boolean
lib.registerHook('ox_lib:setEntityState', function(payload)
    if payload.value then return false end

    local vehicle = lib.vehicle:new(payload.entityId)
    local props = vehicle:get(stateKey) ---@type VehicleProperties?

    if not props then return false end

    if props.plate and props.plate:strtrim() ~= vehicle:getPlate():strtrim() then return false end

    -- we pray
    return true
end, { key = stateKey })