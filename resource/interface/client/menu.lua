local registeredMenus = {}
local openMenu = nil

function lib.registerMenu(data)
    if not registeredMenus[data.id] then registeredMenus[data.id] = data end
end

function lib.showMenu(id)
    if not registeredMenus[id] then return error('No menu of such id found.') end
    local data = registeredMenus[id]
    openMenu = id
    SetNuiFocus(true, true)
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
    -- print(data)
end)

RegisterNUICallback('changeSelected', function(data, cb)
    cb(1)
    if registeredMenus[openMenu].onChange then
        local selected = data
        if type(selected) == 'number' then
            registeredMenus[openMenu].onChange(selected)
        else
            registeredMenus[openMenu].onChange(selected[1], selected[2])
        end
    end
end)

RegisterCommand('testMenu', function()
    lib.registerMenu({
        id = 'epic_menu',
        title = 'Nice menu',
        position = 'top-right',
        onChange = function(selected, scrollIndex)
            print(selected, scrollIndex)
        end,
        options = {
            {label = 'Nice option'},
            {label = 'Nice header', values = {'Option1', 'option2', 'option3'}}
        }
    })
    lib.showMenu('epic_menu')
end)