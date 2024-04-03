local settings = {
    locale = GetResourceKvpString('locale'),
    notification_audio = GetResourceKvpInt('notification_audio') == 1
}

RegisterCommand('ox_lib', function()
    local input = lib.inputDialog('Settings', {
        {
            type = 'select',
            label = locale('ui.settings.locale'),
            searchable = true,
            description = locale('ui.settings.locale_description', settings.locale),
            options = GlobalState['ox_lib:locales'],
            icon = 'book',
        },
        {
            type = 'checkbox',
            label = locale('ui.settings.notification_audio'),
            checked = settings.notification_audio,
        }
    }) --[[@as any]]

    if not input then return end

    if input[1] then lib.setLocale(input[1]) end

    if input[2] ~= nil then
        settings.notification_audio = input[2]
        SetResourceKvpInt('notification_audio', input[2] and 1 or 0)
    end
end)

return settings
