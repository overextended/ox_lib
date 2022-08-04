local registeredMenus = {}
local openMenu = nil

function lib.registerMenu(data, cb)
    if not data.id then return error('No menu id was provided.') end
    if not data.title then return error('No menu title was provided.') end
    if not data.options then return error('No menu options were provided.') end
    data.cb = cb
    registeredMenus[data.id] = data
end

function lib.showMenu(id)
    if not registeredMenus[id] then return error('No menu of such id found.') end
    local data = registeredMenus[id]
    openMenu = id
    SetNuiFocus(true, false)
    SendNUIMessage({
        action = 'setMenu',
        data = {
            position = data.position,
            title = data.title,
            items = data.options
        }
    })
end

function lib.hideMenu(onExit)
	if onExit and registeredMenus[openMenu].onClose then
		registeredMenus[openMenu].onClose()
	end

	SetNuiFocus(false, false)
	SendNUIMessage({
		action = 'closeMenu'
	})
end

function lib.setMenuOptions(id, options, index)
	if index then
		registeredMenus[id].options[index] = options
	else
		registeredMenus[id].options = options
 	end
end

function lib.getOpenMenu() return openMenu end

RegisterNUICallback('confirmSelected', function(data, cb)
    cb(1)
	data[1] += 1 -- selected

	if data[2] then
		data[2] += 1 -- scrollIndex
	end

    local menu = registeredMenus[openMenu]

    if menu.options[data[1]].close ~= false then
		SetNuiFocus(false, false)
	end

	return menu.cb and menu.cb(data[1], data[2], menu.options[data[1]].args)
end)

RegisterNUICallback('changeIndex', function(data, cb)
	cb(1)
	local menu = registeredMenus[openMenu]
	if not menu.onSideScroll then return end

	data[1] += 1 -- selected

	if data[2] then
		data[2] += 1 -- scrollIndex
	end

	menu.onSideScroll(data[1], data[2], menu.options[data[1]].args)
end)

RegisterNUICallback('changeSelected', function(data, cb)
    cb(1)
	local menu = registeredMenus[openMenu]
    if not menu.onSelected then return end

	data[1] += 1 -- selected

	if data[2] then
		data[2] += 1 -- scrollIndex
	end

	menu.onSelected(data[1], data[2], menu.options[data[1]].args)
end)

RegisterNUICallback('closeMenu', function(data, cb)
    cb(1)
    SetNuiFocus(false, false)
    if registeredMenus[openMenu].onClose then return registeredMenus[openMenu].onClose() end
end)
