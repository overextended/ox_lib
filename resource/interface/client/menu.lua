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

function lib.getOpenMenu() return openMenu end

RegisterNUICallback('confirmSelected', function(data, cb)
    cb(1)
    SetNuiFocus(false, false)
    local selected = data
    local args = registeredMenus[openMenu].options[selected+1].args
    if type(selected) == 'number' then
        registeredMenus[openMenu].cb(selected, nil, args)
    else
        registeredMenus[openMenu].cb(selected[1], selected[2], args)
    end
end)

RegisterNUICallback('changeSelected', function(data, cb)
    cb(1)
    if not registeredMenus[openMenu].onChange then return end
    local selected = data
    local args = registeredMenus[openMenu].options[selected+1].args
    if type(selected) == 'number' then
        registeredMenus[openMenu].onChange(selected, nil, args)
    else
        registeredMenus[openMenu].onChange(selected[1], selected[2], args)
    end
end)

RegisterNUICallback('closeMenu', function(data, cb)
    cb(1)
    SetNuiFocus(false, false)
    if registeredMenus[openMenu].onClose then return registeredMenus[openMenu].onClose() end
end)

RegisterCommand('testMenu', function()
    lib.registerMenu({
        id = 'epic_menu',
        title = 'Nice menu',
        options = {
            {label = 'Nice option'},
            {label = 'Nice header', values = {'Option1', 'option2', 'option3'}, description = 'Tooltip description'}
        }
    }, function(selected, scrollIndex, args)
        lib.registerMenu({
            id = 'more_epic_menu',
            title = 'Nicer menu',
            position = 'top-right',
            onClose = function()
                lib.showMenu('epic_menu')
            end,
            options = {
                {label = 'Extra nice option', args = 'Hello there'},
                {label = 'Giga nice option'},
                {label = 'Omega nice option'},
            }
        }, function(selected, scrollIndex, args)
            print(selected, scrollIndex, args)
         end)
        lib.showMenu('more_epic_menu')
    end)
    lib.showMenu('epic_menu')
end)