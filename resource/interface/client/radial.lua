local isOpen = false
local menus = {}
local menuItems = {}
local currentRadial = nil

---@class RadialMenuItem
---@field id string
---@field icon string
---@field label string
---@field menu? string
---@field onSelect? function

---@class RadialMenuProps
---@field id string
---@field items RadialMenuItem[]

---Registers a radial sub menu with predefined options.
---@param radial RadialMenuProps
function lib.registerRadial(radial)
    menus[radial.id] = radial
end

---Open a registered radial submenu with the given id.
---@param id string
local function showRadial(id)
    local radial = menus[id]

    if not radial then return error('No radial menu with such id found.') end

    currentRadial = radial

    -- Hide current menu and allow for transition
    SendNUIMessage({
        action = 'openRadialMenu',
        data = false
    })

    Wait(100)

    -- If menu was closed during transition, don't open the submenu
    if not isOpen then return end

    SendNUIMessage({
        action = 'openRadialMenu',
        data = {
            items = radial.items,
            sub = true
        }
    })
end

function lib.hideRadial()
    if not isOpen then return end

    SendNUIMessage({
        action = 'openRadialMenu',
        data = false
    })

    SetNuiFocus(false, false)

    isOpen = false
    currentRadial = nil
end

---Registers an item or array of items in the global radial menu.
---@param items RadialMenuItem | RadialMenuItem[]
function lib.addRadialItem(items)
    local menuSize = #menuItems
    local invokingResource = GetInvokingResource()

    if table.type(items) == 'array' then
        for i = 1, #items do
            local item = items[i]
            item.resource = invokingResource
            menuSize += 1
            menuItems[menuSize] = item
        end
    else
        items.resource = invokingResource
        menuItems[menuSize + 1] = items
    end

    if isOpen then
        SendNUIMessage({
            action = 'refreshItems',
            data = menuItems
        })
    end
end

---Removes an item from the global radial menu with the given id.
---@param id string
function lib.removeRadialItem(id)
    for i = 1, #menuItems do
        local item = menuItems[i]
        if item.id == id then
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

    lib.hideRadial()

    if item.onSelect then item.onSelect() end
    if item.menu then return showRadial(item.menu) end

end)

RegisterNUICallback('radialBack', function(_, cb)
    cb(1)
    if currentRadial.menu then
        return showRadial(currentRadial.menu)
    end

    currentRadial = nil

    SendNUIMessage({
        action = 'openRadialMenu',
        data = {
            items = menuItems
        }
    })
end)

RegisterNUICallback('radialClose', function(_, cb)
    cb(1)

    if not isOpen then return end

    SetNuiFocus(false, false)

    isOpen = false
    currentRadial = nil
end)

lib.addKeybind({
    name = 'ox_lib-radial',
    description = 'Open radial menu',
    defaultKey = 'z',
    onPressed = function()
        if isOpen then
            return lib.hideRadial()
        end

        if #menuItems == 0 or IsNuiFocused() or IsPauseMenuActive() then return end

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

        while isOpen do
            DisablePlayerFiring(cache.playerId, true)
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            Wait(0)
        end
    end,
    -- onReleased = lib.hideRadial,
})

AddEventHandler('onClientResourceStop', function(resource)
    for i = #menuItems, 1, -1 do
        local item = menuItems[i]

        if item.resource == resource then
            table.remove(menuItems, i)
        end
    end
end)
