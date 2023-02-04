local isOpen = false
local menus = {}
local menuItems = {}
local currentRadial = nil


function lib.registerRadial(radial)
    menus[radial.id] = radial
end

function lib.showRadial(id)
    local radial = menus[id]
    if not radial then return error('No radial menu with such id found.') end
    currentRadial = radial
    SendNUIMessage({
        action = 'openRadialMenu',
        data = {
            items = radial.items,
            sub = true
        }
    })
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

RegisterNUICallback('radialClick', function(index, cb)
    cb(1)
    local item = not currentRadial and menuItems[index + 1] or currentRadial.items[index + 1]
    if item.menu then lib.showRadial(item.menu) end
    if item.onSelect then item.onSelect() end
end)

-- TODO: fix transition?
RegisterNUICallback('radialBack', function(_, cb)
    cb(1)
    if currentRadial.menu then
        lib.showRadial(currentRadial.menu)
    else
        currentRadial = nil
        SendNUIMessage({
            action = 'openRadialMenu',
            data = {
                items = menuItems
            }
        })
    end
end)

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
    SetCursorLocation(0.5, 0.5)
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
    if currentRadial then currentRadial = nil end
end

RegisterCommand('+ox_lib-radial', openRadial)

RegisterCommand('-ox_lib-radial', closeRadial)

RegisterKeyMapping('+ox_lib-radial', 'Open radial menu', 'keyboard', 'z')