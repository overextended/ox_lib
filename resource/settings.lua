local settings = {
    locale = GetResourceKvpString('locale'),
}

if not settings.locale then lib.setLocale(GetConvar('ox:locale', 'en')) end

RegisterCommand('ox_lib', function()
    local input = lib.inputDialog('Settings', {
        {
            type = 'select',
            label = locale('ui.settings.locale'),
            searchable = true,
            description = locale('ui.settings.locale_description', settings.locale),
            options = GlobalState['ox_lib:locales'],
            icon = 'book',
        }
    }) --[[@as any]]

    if not input then return end

    if input[1] then lib.setLocale(input[1]) end
end)

return settings
