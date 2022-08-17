local alert = nil

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

RegisterNUICallback('closeAlert', function(data, cb)
    cb(1)
    SetNuiFocus(false, false)
    local promise = alert
    alert = nil
    promise:resolve(data)
end)

RegisterNetEvent('ox_lib:alertDialog', lib.alertDialog)
