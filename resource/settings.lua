local settings = {
    locale = GetResourceKvpString('locale'),
    notification_position = GetResourceKvpString('notification_position') or 'top-right',
    notification_audio = GetResourceKvpInt('notification_audio') == 1
}

local function set(key, value)
    if settings[key] == value then return false end

    settings[key] = value
    local valueType = type(value)

    if valueType == 'nil' then
        DeleteResourceKvp(key)
    elseif valueType == 'string' then
        SetResourceKvp(key, value)
    elseif valueType == 'table' then
        SetResourceKvp(key, json.encode(value))
    elseif valueType == 'number' then
        SetResourceKvpInt(key, value)
    elseif valueType == 'boolean' then
        SetResourceKvpInt(key, value and 1 or 0)
    else
        return false
    end

    return true
end

RegisterCommand('ox_lib', function()
    local input = lib.inputDialog('Settings', {
        {
            type = 'select',
            label = locale('ui.settings.locale'),
            searchable = true,
            description = locale('ui.settings.locale_description', settings.locale),
            options = GlobalState['ox_lib:locales'],
            default = settings.locale,
            required = true,
            icon = 'book',
        },
        {
            type = 'select',
            label = locale('ui.settings.notification_position'),
            options = {
                { label = locale('ui.position.top-right'),    value = 'top-right' },
                { label = locale('ui.position.top'),          value = 'top' },
                { label = locale('ui.position.top-left'),     value = 'top-left' },
                { label = locale('ui.position.center-right'), value = 'center-right' },
                { label = locale('ui.position.center-left'),  value = 'center-left' },
                { label = locale('ui.position.bottom-right'), value = 'bottom-right' },
                { label = locale('ui.position.bottom'),       value = 'bottom' },
                { label = locale('ui.position.bottom-left'),  value = 'bottom-left' },
            },
            default = settings.notification_position,
            required = true,
            icon = 'message',
        },
        {
            type = 'checkbox',
            label = locale('ui.settings.notification_audio'),
            checked = settings.notification_audio,
        }
    }) --[[@as table?]]

    if not input then return end

    ---@type string, string, boolean
    local locale, notification_position, notification_audio = table.unpack(input)

    if set('locale', locale) then lib.setLocale(locale) end

    set('notification_position', notification_position)
    set('notification_audio', notification_audio)
end)

return settings
