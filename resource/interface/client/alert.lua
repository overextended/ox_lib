function lib.alertDialog(data)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'sendAlert',
        data = data
    })
end

RegisterNUICallback('closeAlert', function(_, cb)
    cb(1)
    SetNuiFocus(false, false)
end)

RegisterNetEvent('ox_lib:alertDialog', lib.alertDialog)
