--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@type promise?
local alert = nil
local alertId = 0

---@class AlertDialogProps
---@field header string;
---@field content string;
---@field centered? boolean?;
---@field size? 'xs' | 'sm' | 'md' | 'lg' | 'xl';
---@field overflow? boolean?;
---@field cancel? boolean?;
---@field labels? {cancel?: string, confirm?: string}

---@param data AlertDialogProps
---@param timeout? number Force the window to timeout after `x` milliseconds.
---@return 'cancel' | 'confirm' | nil
function lib.alertDialog(data, timeout)
    if alert then return end

    local id = alertId + 1
    alertId = id
    alert = promise.new()

    lib.setNuiFocus(false)
    SendNUIMessage({
        action = 'sendAlert',
        data = data
    })

    if timeout then
        SetTimeout(timeout, function()
            if id == alertId then lib.closeAlertDialog('timeout') end
        end)
    end

    return Citizen.Await(alert)
end

---@param reason? string An optional reason for the window to be closed.
function lib.closeAlertDialog(reason)
    if not alert then return end

    lib.resetNuiFocus()
    SendNUIMessage({
        action = 'closeAlertDialog'
    })

    local p = alert
    alert = nil

    if reason then p:reject(reason) else p:resolve() end
end

RegisterNUICallback('closeAlert', function(data, cb)
    cb(1)
    lib.resetNuiFocus()

    local promise = alert --[[@as promise]]
    alert = nil

    promise:resolve(data)
end)

RegisterNetEvent('ox_lib:alertDialog', lib.alertDialog)
