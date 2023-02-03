local isOpen = false
local menuItems = {}

function lib.addRadialItem(items)
    if table.type(items) == 'array' then
        for i = 1, #items do
            local item = items[i]
            menuItems[#menuItems+1] = item
        end
    else
        menuItems[#menuItems+1] = items
    end
end

function lib.removeRadialItem(key)
    for i = 1, #menuItems do
        local item = menuItems[i]
        if item.key == key then
            table.remove(menuItems, i)
            break
        end
    end
    if isOpen then
        SendNUIMessage({
            action = 'refreshItems',
            data = menuItems
        })
    end
end

local function openRadial()
    isOpen = true
    SendNUIMessage({
        action = 'openRadialMenu',
        data = {
            items = menuItems
        }
    })
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    CreateThread(function()
        while isOpen do
            DisablePlayerFiring(cache.playerId, true)
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            Wait(0)
        end
    end)
end

local function closeRadial()
    SendNUIMessage({
        action = 'openRadialMenu',
        data = false
    })
    SetNuiFocus(false, false)
    isOpen = false
end

RegisterCommand('+ox_lib-radial', openRadial)

RegisterCommand('-ox_lib-radial', closeRadial)

RegisterKeyMapping('+ox_lib-radial', 'Open radial menu', 'keyboard', 'z')