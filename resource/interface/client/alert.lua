local alert = nil

---@class AlertDialogProps
---@field header string;
---@field content string;
---@field centered? boolean?;
---@field cancel? boolean?;

---@param data AlertDialogProps
---@return 'cancel' | 'confirm' | nil
function lib.alertDialog(data)
    if alert then return end
    alert = promise.new()

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'sendAlert',
        data = data
    })

    return Citizen.Await(alert)
end

function lib.closeAlertDialog()
    if not alert then return end
    alert:resolve(nil)
    alert = nil
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeAlertDialog'
    })
end


RegisterNUICallback('closeAlert', function(data, cb)
    cb(1)
    SetNuiFocus(false, false)
    local promise = alert
    alert = nil
    promise:resolve(data)
end)

RegisterNetEvent('ox_lib:alertDialog', lib.alertDialog)