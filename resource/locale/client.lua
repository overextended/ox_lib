local userLocale = GetResourceKvpString('locale')

local function loadLocale(locale, cb)
	local JSON = LoadResourceFile('ox_lib', ('locales/%s.json'):format(locale)) or LoadResourceFile('ox_lib', ('locales/en.json'):format(locale))
	if cb then cb(JSON) end

	SetResourceKvp('locale', locale)
	TriggerEvent('ox_lib:setLocale', locale)
end

RegisterNUICallback('getLocale', loadLocale)

if not userLocale then
	local default = { 'en', 'fr', 'de', 'it', 'es', 'pt-BR', 'pl', 'ru', 'ko', 'zh-TW', 'ja', 'es-MX', 'zh-CN' }
	userLocale = default[GetCurrentLanguage() + 1]
end

loadLocale(userLocale)

RegisterCommand('setlocale', function(_, args, _)
	if args?[1] then
		loadLocale(args[1])
	end
end, false)
