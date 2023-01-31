local isOpen = false
local menuItems = {}

function lib.addRadialItem(items)
    if table.type(items) == 'array' then
        for i = 1, #items do
            local itemOption = items[i]
            menuItems[#menuItems+1] = itemOption
        end
    else
        menuItems[#menuItems+1] = items
    end
end

-- TODO: Interval canInteract checking and sending new items to NUI
local function openRadial()
    isOpen = true
    local items = {}
    for i = 1, #menuItems do
        local menuItem = menuItems[i]
        if menuItem.canInteract == nil or menuItem.canInteract() then
            items[#items+1] = {
                icon = menuItem.icon,
                label = menuItem.label
            }
        end
    end
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