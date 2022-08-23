local registeredMenus = {}
local openMenu = nil
local keepInput = IsNuiFocusKeepingInput()

function lib.registerMenu(data, cb)
    if not data.id then return error('No menu id was provided.') end
    if not data.title then return error('No menu title was provided.') end
    if not data.options then return error('No menu options were provided.') end
    data.cb = cb
    registeredMenus[data.id] = data
end

function lib.showMenu(id)
	local menu = registeredMenus[id]

	if not menu then
		return error(('No menu with id %s was found'):format(id))
	end

	if not openMenu then
		CreateThread(function()
			while openMenu do
				if not openMenu.disableInput then
					DisablePlayerFiring(cache.playerId, true)
					HudWeaponWheelIgnoreSelection()
					DisableControlAction(0, 140, true)
				end

				Wait(0)
			end
		end)
	end

	openMenu = menu
	keepInput = IsNuiFocusKeepingInput()

	if not menu.disableInput then
		SetNuiFocusKeepInput(true)
	end

    SetNuiFocus(true, false)
    SendNUIMessage({
        action = 'setMenu',
        data = {
            position = menu.position,
            title = menu.title,
            items = menu.options
        }
    })
end

local function resetFocus()
	SetNuiFocus(false, false)
	SetNuiFocusKeepInput(keepInput)
end

function lib.hideMenu(onExit)
	local menu = openMenu
	openMenu = nil

	if onExit and menu.onClose then
		menu.onClose()
	end

	resetFocus()
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

	local menu = openMenu
	openMenu = nil

    if menu.options[data[1]].close ~= false then
		resetFocus()
	end

	if menu.cb then
		menu.cb(data[1], data[2], menu.options[data[1]].args)
	end

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
    resetFocus()

	local menu = openMenu
	openMenu = nil

    if menu.onClose then
		menu.onClose()
	end
end)
