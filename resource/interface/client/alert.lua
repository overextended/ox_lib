local alert = nil

---@class AlertDialogProps
---@field header string;
---@field content string;
---@field centered? boolean?;
---@field size? 'xs' | 'sm' | 'md' | 'lg' | 'xl';
---@field overflow? boolean?;
---@field cancel? boolean?;
---@field labels? {cancel?: string, confirm?: string}

---@param data AlertDialogProps
---@return 'cancel' | 'confirm' | nil
function lib.alertDialog(data)
    if alert then return end

    alert = promise.new()

    lib.setNuiFocus(false)
    SendNUIMessage({
        action = 'sendAlert',
        data = data
    })

    return Citizen.Await(alert)
end

function lib.closeAlertDialog()
    if not alert then return end

    lib.resetNuiFocus()
    SendNUIMessage({
        action = 'closeAlertDialog'
    })

    alert:resolve(nil)
    alert = nil
end


RegisterNUICallback('closeAlert', function(data, cb)
    cb(1)
    lib.resetNuiFocus()

    local promise = alert
    alert = nil

    promise:resolve(data)
end)

RegisterNetEvent('ox_lib:alertDialog', lib.alertDialog)
