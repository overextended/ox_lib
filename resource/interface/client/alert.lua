local alert = nil
local keepInput = IsNuiFocusKeepingInput()

local function resetFocus()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(keepInput)
end

---@class AlertDialogProps
---@field header string;
---@field content string;
---@field centered? boolean?;
---@field cancel? boolean?;
---@field labels? {cancel?: string, confirm?: string}

---@param data AlertDialogProps
---@return 'cancel' | 'confirm' | nil
function lib.alertDialog(data)
    if alert then return end
    alert = promise.new()

    keepInput = IsNuiFocusKeepingInput()

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
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
    resetFocus()
    SendNUIMessage({
        action = 'closeAlertDialog'
    })
end


RegisterNUICallback('closeAlert', function(data, cb)
    cb(1)
    resetFocus()
    local promise = alert
    alert = nil
    promise:resolve(data)
end)

RegisterNetEvent('ox_lib:alertDialog', lib.alertDialog)
