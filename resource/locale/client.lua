---@todo remove module and nui event
RegisterNUICallback('init', function(_, cb)
    cb(1)

    SendNUIMessage({
        action = 'loadLocales',
        data = {}
    })
end)
