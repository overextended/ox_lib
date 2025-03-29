--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@param vehicle number
---@param props VehicleProperties
---@diagnostic disable-next-line: duplicate-set-field
function lib.setVehicleProperties(vehicle, props)
    Entity(vehicle).state:set('ox_lib:setVehicleProperties', props, true)
end
