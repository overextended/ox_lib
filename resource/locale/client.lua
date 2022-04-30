local default = { 'en', 'fr', 'de', 'it', 'es', 'pt-BR', 'pl', 'ru', 'ko', 'zh-TW', 'ja', 'es-MX', 'zh-CN' }
local userLocale = GetResourceKvpString('locale')

local function loadLocale(locale, cb)
	if cb then cb(1) end
	local JSON = LoadResourceFile('ox_lib', ('locales/%s.json'):format(locale)) or LoadResourceFile('ox_lib', ('locales/en.json'):format(locale))
	SendNUIMessage({
		action = 'setLocale',
		data = json.decode(JSON)
	})
	SetResourceKvp('locale', locale)
	TriggerEvent('ox_lib:setLocale', locale)
end

RegisterNUICallback('getLocale', loadLocale)

RegisterNUICallback('closeSettings', function(_, cb)
	cb(1)
	SetNuiFocus(false, false)
end)

if not userLocale then userLocale = default[GetCurrentLanguage() + 1] end

RegisterNUICallback('init', function(_, cb)
	cb(1)
	loadLocale(userLocale)
	SendNUIMessage({ -- Loads the `default` array into select options
		action = 'loadLocales',
		data = default
	})
end)

RegisterCommand('ox_lib', function()
	SendNUIMessage({
		action = 'openSettings',
		data = GetResourceKvpString('locale') -- Sets the value for language select
	})
	SetNuiFocus(true, true)
end)

RegisterCommand('setlocale', function(_, args, _)
	if args?[1] then
		loadLocale(args[1])
	end
end, false)
