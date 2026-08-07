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
        DeleteResourceKvp(key)
        return default
    end

    return result or default
end

local settings = {
    default_locale = GetConvar('ox:locale', 'en'),
    notification_position = safeGetKvp(GetResourceKvpString, 'notification_position', 'top-right'),
    notification_audio = safeGetKvp(GetResourceKvpInt, 'notification_audio') == 1
}

local userLocales = GetConvarInt('ox:userLocales', 1) == 1

settings.locale = userLocales and safeGetKvp(GetResourceKvpString, 'locale') or settings.default_locale

local colorblindModes = {
    off = {
        label = 'ui.settings.colorblind_modes.off',
        primaryColor = GetConvar('ox:primaryColor', 'blue'),
        primaryShade = GetConvarInt('ox:primaryShade', 8),
        indicatorColor = 'red',
        indicatorShade = 6,
    },
    protanopia = {
        label = 'ui.settings.colorblind_modes.protanopia',
        primaryColor = 'cyan',
        primaryShade = 6,
        indicatorColor = 'orange',
        indicatorShade = 6,
    },
    deuteranopia = {
        label = 'ui.settings.colorblind_modes.deuteranopia',
        primaryColor = 'blue',
        primaryShade = 6,
        indicatorColor = 'orange',
        indicatorShade = 6,
    },
    tritanopia = {
        label = 'ui.settings.colorblind_modes.tritanopia',
        primaryColor = 'pink',
        primaryShade = 6,
        indicatorColor = 'green',
        indicatorShade = 6,
    },
    achromatopsia = {
        label = 'ui.settings.colorblind_modes.achromatopsia',
        primaryColor = 'gray',
        primaryShade = 7,
        indicatorColor = 'yellow',
        indicatorShade = 4,
    },
}

local function getColorblindData(mode)
    return colorblindModes[mode] or colorblindModes.off
end

settings.colorblind_mode = safeGetKvp(GetResourceKvpString, 'colorblind_mode', 'off')

if not colorblindModes[settings.colorblind_mode] then
    settings.colorblind_mode = 'off'
    DeleteResourceKvp('colorblind_mode')
end

function settings.getColorblindConfig()
    local colorblindData = getColorblindData(settings.colorblind_mode)

    return {
        colorblindMode = settings.colorblind_mode,
        primaryColor = colorblindData.primaryColor,
        primaryShade = colorblindData.primaryShade,
    }
end

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

local function syncColorblindMode(mode)
    if not colorblindModes[mode] then return false end

    if not set('colorblind_mode', mode) then return false end

    SendNUIMessage({
        action = 'setColorblindMode',
        data = mode,
    })

    return true
end

local function openColorblindMenu()
    if not lib.registerContext or not lib.showContext then
        local input = lib.inputDialog(locale('ui.settings.colorblind'), {
            {
                type = 'select',
                label = locale('ui.settings.colorblind'),
                default = settings.colorblind_mode,
                required = true,
                options = {
                    { label = locale('ui.settings.colorblind_modes.off'), value = 'off' },
                    { label = locale('ui.settings.colorblind_modes.protanopia'), value = 'protanopia' },
                    { label = locale('ui.settings.colorblind_modes.deuteranopia'), value = 'deuteranopia' },
                    { label = locale('ui.settings.colorblind_modes.tritanopia'), value = 'tritanopia' },
                    { label = locale('ui.settings.colorblind_modes.achromatopsia'), value = 'achromatopsia' },
                }
            }
        }) --[[@as table?]]

        if not input then return end

        local mode = input[1]

        if mode and syncColorblindMode(mode) then
            lib.notify({
                title = locale('settings'),
                description = locale('ui.settings.colorblind_saved', locale(getColorblindData(mode).label)),
                type = 'success'
            })
        end

        return
    end

    local options = {
        {
            title = locale('ui.settings.colorblind_modes.off'),
            description = settings.colorblind_mode == 'off' and locale('ui.settings.colorblind_current') or nil,
            icon = settings.colorblind_mode == 'off' and 'check' or 'circle',
            onSelect = function()
                syncColorblindMode('off')
                lib.notify({
                    title = locale('settings'),
                    description = locale('ui.settings.colorblind_saved', locale('ui.settings.colorblind_modes.off')),
                    type = 'success'
                })
            end,
        },
        {
            title = locale('ui.settings.colorblind_modes.protanopia'),
            description = settings.colorblind_mode == 'protanopia' and locale('ui.settings.colorblind_current') or nil,
            icon = settings.colorblind_mode == 'protanopia' and 'check' or 'circle',
            onSelect = function()
                syncColorblindMode('protanopia')
                lib.notify({
                    title = locale('settings'),
                    description = locale('ui.settings.colorblind_saved', locale('ui.settings.colorblind_modes.protanopia')),
                    type = 'success'
                })
            end,
        },
        {
            title = locale('ui.settings.colorblind_modes.deuteranopia'),
            description = settings.colorblind_mode == 'deuteranopia' and locale('ui.settings.colorblind_current') or nil,
            icon = settings.colorblind_mode == 'deuteranopia' and 'check' or 'circle',
            onSelect = function()
                syncColorblindMode('deuteranopia')
                lib.notify({
                    title = locale('settings'),
                    description = locale('ui.settings.colorblind_saved', locale('ui.settings.colorblind_modes.deuteranopia')),
                    type = 'success'
                })
            end,
        },
        {
            title = locale('ui.settings.colorblind_modes.tritanopia'),
            description = settings.colorblind_mode == 'tritanopia' and locale('ui.settings.colorblind_current') or nil,
            icon = settings.colorblind_mode == 'tritanopia' and 'check' or 'circle',
            onSelect = function()
                syncColorblindMode('tritanopia')
                lib.notify({
                    title = locale('settings'),
                    description = locale('ui.settings.colorblind_saved', locale('ui.settings.colorblind_modes.tritanopia')),
                    type = 'success'
                })
            end,
        },
        {
            title = locale('ui.settings.colorblind_modes.achromatopsia'),
            description = settings.colorblind_mode == 'achromatopsia' and locale('ui.settings.colorblind_current') or nil,
            icon = settings.colorblind_mode == 'achromatopsia' and 'check' or 'circle',
            onSelect = function()
                syncColorblindMode('achromatopsia')
                lib.notify({
                    title = locale('settings'),
                    description = locale('ui.settings.colorblind_saved', locale('ui.settings.colorblind_modes.achromatopsia')),
                    type = 'success'
                })
            end,
        },
    }

    lib.registerContext({
        id = 'ox_lib_colorblind',
        title = locale('ui.settings.colorblind'),
        options = options,
    })

    local ok = pcall(lib.showContext, 'ox_lib_colorblind')

    if ok then return end

    local input = lib.inputDialog(locale('ui.settings.colorblind'), {
        {
            type = 'select',
            label = locale('ui.settings.colorblind'),
            default = settings.colorblind_mode,
            required = true,
            options = {
                { label = locale('ui.settings.colorblind_modes.off'), value = 'off' },
                { label = locale('ui.settings.colorblind_modes.protanopia'), value = 'protanopia' },
                { label = locale('ui.settings.colorblind_modes.deuteranopia'), value = 'deuteranopia' },
                { label = locale('ui.settings.colorblind_modes.tritanopia'), value = 'tritanopia' },
                { label = locale('ui.settings.colorblind_modes.achromatopsia'), value = 'achromatopsia' },
            }
        }
    }) --[[@as table?]]

    if not input then return end

    local mode = input[1]

    if mode and syncColorblindMode(mode) then
        lib.notify({
            title = locale('settings'),
            description = locale('ui.settings.colorblind_saved', locale(getColorblindData(mode).label)),
            type = 'success'
        })
    end
end

RegisterNUICallback('syncColorblindMode', function(data, cb)
    local mode = type(data) == 'table' and data.mode or nil

    if mode and colorblindModes[mode] then
        syncColorblindMode(mode)
    end

    cb(1)
end)

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
            label = locale('ui.settings.colorblind'),
            options = {
                { label = locale('ui.settings.colorblind_modes.off'), value = 'off' },
                { label = locale('ui.settings.colorblind_modes.protanopia'), value = 'protanopia' },
                { label = locale('ui.settings.colorblind_modes.deuteranopia'), value = 'deuteranopia' },
                { label = locale('ui.settings.colorblind_modes.tritanopia'), value = 'tritanopia' },
                { label = locale('ui.settings.colorblind_modes.achromatopsia'), value = 'achromatopsia' },
            },
            default = settings.colorblind_mode,
            required = true,
            icon = 'eye',
        },
        {
            type = 'select',
            label = locale('ui.settings.ui_test_action'),
            options = {
                { label = locale('ui.settings.ui_test_action_none'), value = 'none' },
                { label = locale('ui.settings.ui_test_action_circle'), value = 'circle' },
            },
            default = 'none',
            required = true,
            icon = 'flask',
        },
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

    local notification_audio = input[1]
    local notification_position = input[2]
    local colorblind_mode = input[3]
    local ui_test_action = input[4]
    local localeInput = userLocales and input[5] or nil

    if userLocales and set('locale', localeInput) then lib.setLocale(localeInput) end

    set('notification_position', notification_position)
    set('notification_audio', notification_audio)
    syncColorblindMode(colorblind_mode)

    if ui_test_action == 'circle' then
        CreateThread(function()
            lib.progressCircle({
                duration = 5000,
                label = locale('ui.settings.ui_test_action_circle'),
                position = 'middle',
                canCancel = true,
            })
        end)
    end
end, false)

return settings
