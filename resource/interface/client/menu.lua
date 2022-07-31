local registeredMenus = {}
local openMenu = nil

function lib.registerMenu(data, cb)
    data.cb = cb
    if not registeredMenus[data.id] then registeredMenus[data.id] = data end
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
    if type(selected) == 'number' then
        registeredMenus[openMenu].cb(selected)
    else
        registeredMenus[openMenu].cb(selected[1], selected[2])
    end
end)

RegisterNUICallback('changeSelected', function(data, cb)
    cb(1)
    if not registeredMenus[openMenu].onChange then return end
    local selected = data
    if type(selected) == 'number' then
        registeredMenus[openMenu].onChange(selected)
    else
        registeredMenus[openMenu].onChange(selected[1], selected[2])
    end
end)

RegisterCommand('testMenu', function()
    lib.registerMenu({
        id = 'epic_menu',
        title = 'Nice menu',
        onChange = function(selected, scrollIndex)
            print(selected, scrollIndex)
        end,
        options = {
            {label = 'Nice option'},
            {label = 'Nice header', values = {'Option1', 'option2', 'option3'}}
        }
    }, function(selected, scrollIndex)
        print(selected, scrollIndex)
        lib.registerMenu({
            id = 'more_epic_menu',
            title = 'Nicer menu',
            position = 'top-right',
            options = {
                {label = 'Extra nice option'},
                {label = 'Giga nice option'},
                {label = 'Omega nice option'},
            }
        }, function() end)
        lib.showMenu('more_epic_menu')
    end)
    lib.showMenu('epic_menu')
end)