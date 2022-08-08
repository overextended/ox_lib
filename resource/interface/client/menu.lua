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
	openMenu = registeredMenus[id]

	if not openMenu then
		return error(('No menu with id %s was found'):format(id))
	end

    SetNuiFocus(true, false)
    SendNUIMessage({
        action = 'setMenu',
        data = {
            position = openMenu.position,
            title = openMenu.title,
            items = openMenu.options
        }
    })
end

function lib.hideMenu(onExit)
	if onExit and openMenu.onClose then
		openMenu.onClose()
	end

	openMenu = nil
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

    if openMenu.options[data[1]].close ~= false then
		SetNuiFocus(false, false)
	end

	if openMenu.cb then
		openMenu.cb(data[1], data[2], openMenu.options[data[1]].args)
	end

	openMenu = nil
end)

RegisterNUICallback('changeIndex', function(data, cb)
	cb(1)
	if not openMenu.onSideScroll then return end

	data[1] += 1 -- selected

	if data[2] then
		data[2] += 1 -- scrollIndex
	end

	openMenu.onSideScroll(data[1], data[2], openMenu.options[data[1]].args)
end)

RegisterNUICallback('changeSelected', function(data, cb)
    cb(1)
    if not openMenu.onSelected then return end

	data[1] += 1 -- selected

	if data[2] then
		data[2] += 1 -- scrollIndex
	end

	openMenu.onSelected(data[1], data[2], openMenu.options[data[1]].args)
end)

RegisterNUICallback('closeMenu', function(data, cb)
    cb(1)
    SetNuiFocus(false, false)

    if openMenu.onClose then
		openMenu.onClose()
	end

	openMenu = nil
end)
