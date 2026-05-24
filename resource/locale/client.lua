--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local settings = require 'resource.settings'

lib.locale(settings.locale)

function lib.getLocaleKey() return settings.locale end

---@param key string
function lib.setLocale(key)
    TriggerEvent('ox_lib:setLocale', key)
    SendNUIMessage({
        action = 'setLocale',
        data = lib.loadLocaleData(key)
    })
end

RegisterNUICallback('init', function(_, cb)
    cb(1)

    SendNUIMessage({
        action = 'setLocale',
        data = lib.loadLocaleData(settings.locale)
    })
end)
