-- Some users have locale set from ox_lib v2
if GetResourceKvpInt('reset_locale') ~= 1 then
    DeleteResourceKvp('locale')
    SetResourceKvpInt('reset_locale', 1)
end

---@generic T
---@param fn fun(key): unknown
---@param key string
---@param default? T
---@return T
local function safeGetKvp(fn, key, default)
    local ok, result = pcall(fn, key)

    if not ok then
        return DeleteResourceKvp(key)
    end

    return result or default
end

local settings = {
    default_locale = GetConvar('ox:locale', 'en'),
    notification_position = safeGetKvp(GetResourceKvpString, 'notification_position', 'top-right'),
    notification_audio = safeGetKvp(GetResourceKvpInt, 'notification_audio') == 1,
    primaryColor = safeGetKvp(GetResourceKvpString, 'primaryColor', 'blue'),
    primaryShade = safeGetKvp(GetResourceKvpInt, 'primaryShade', 6),
}

local userLocales = GetConvarInt('ox:userLocales', 1) == 1

settings.locale = userLocales and safeGetKvp(GetResourceKvpString, 'locale') or settings.default_locale

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
    local inputSettings = {
        {
            type = 'checkbox',
            label = locale('ui.settings.notification_audio'),
            checked = settings.notification_audio,
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
            type = 'select',
            label = locale('ui.settings.primaryColor'),
            options = {
                { label = 'Dark', value = 'dark' },
                { label = 'Gray', value = 'gray' },
                { label = 'Red', value = 'red' },
                { label = 'Pink', value = 'pink' },
                { label = 'Grape', value = 'grape' },
                { label = 'Violet', value = 'violet' },
                { label = 'Indigo', value = 'indigo' },
                { label = 'Blue', value = 'blue' },
                { label = 'Cyan', value = 'cyan' },
                { label = 'Teal', value = 'teal' },
                { label = 'Green', value = 'green' },
                { label = 'Lime', value = 'lime' },
                { label = 'Yellow', value = 'yellow' },
                { label = 'Orange', value = 'orange' },
            },
            default = settings.primaryColor,
            required = true,
            icon = 'palette',
        },
        {
            type = 'select',
            label = locale('ui.settings.primaryShade'),
            options = {
                { label = 'Shade 0', value = 0 },
                { label = 'Shade 1', value = 1 },
                { label = 'Shade 2', value = 2 },
                { label = 'Shade 3', value = 3 },
                { label = 'Shade 4', value = 4 },
                { label = 'Shade 5', value = 5 },
                { label = 'Shade 6', value = 6 },
                { label = 'Shade 7', value = 7 },
                { label = 'Shade 8', value = 8 },
                { label = 'Shade 9', value = 9 },
            },
            default = settings.primaryShade,
            required = true,
            icon = 'adjust',
        }
    }

    if userLocales then
        table.insert(inputSettings,
            {
                type = 'select',
                label = locale('ui.settings.locale'),
                searchable = true,
                description = locale('ui.settings.locale_description', settings.locale),
                options = GlobalState['ox_lib:locales'],
                default = settings.locale,
                required = true,
                icon = 'book',
            })
    end

    local input = lib.inputDialog(locale('settings'), inputSettings) --[[@as table?]]

    if not input then return end

    ---@type boolean, string, string, string, number
    local notification_audio, notification_position, locale, primaryColor, primaryShade = table.unpack(input)

    if set('locale', locale) then lib.setLocale(locale) end

    set('notification_position', notification_position)
    set('notification_audio', notification_audio)
    set('primaryColor', primaryColor)
    set('primaryShade', primaryShade)

    SendReactMessage('updateColorSettings', {
        primaryColor = primaryColor,
        primaryShade = primaryShade
    })
end)

CreateThread(function()
    Wait(500)
    SendReactMessage('updateColorSettings', {
        primaryColor = settings.primaryColor,
        primaryShade = settings.primaryShade
    })
end)

return settings
