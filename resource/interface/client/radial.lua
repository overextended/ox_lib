local isOpen = false
local menuItems = {}
local activeItems = {}

local function getActiveItems()
    activeItems = {}
    for i = 1, #menuItems do
        local item = menuItems[i]
        if item.canInteract == nil or item.canInteract() then
            activeItems[#activeItems+1] = {
                icon = item.icon,
                label = item.label,
                key = item.key
            }
        end
    end
    return activeItems
end

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
        end
    end
    if isOpen then
        local refresh = false
        for i = 1, #activeItems do
            local activeItem = activeItems[i]
            if activeItem.key == key then
                table.remove(activeItems, i)
                refresh = true
            end
        end
        if refresh then
            local items = getActiveItems()
            SendNUIMessage({
                action = 'refreshItems',
                data = items
            })
        end
    end
end

-- TODO: Interval canInteract checking and sending new items to NUI
local function openRadial()
    isOpen = true
    local items = getActiveItems()
    SendNUIMessage({
        action = 'openRadialMenu',
        data = {
            items = items
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