local isOpen = 0
local menus = {}
local onGlobalMenu = false
local currentRadial = nil
local prevMenuHistory = {}
local globalMenus = {}
local MAX_ITEMS <const> = GetConvarInt('ox:radialMaxItems', 6)
local GLOBL_MENU_PREFIX <const> = 'ox:radial_global_'
local find = string.find

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
    if menus[radial.id.."_1"] then
        local submenuId = 1
        while menus[radial.id.."_"..submenuId] do
            menus[radial.id.."_"..submenuId] = nil
            submenuId = submenuId + 1
        end
    end

    local numberItems = #radial.items
    if numberItems > MAX_ITEMS then
        local numberMenus = math.ceil(numberItems / MAX_ITEMS)
        for i = 1, numberMenus do
            local menu = {
                id = radial.id .. '_' .. i,
                items = {}
            }
            for j = 1, MAX_ITEMS do
                local index = (i - 1) * MAX_ITEMS + j
                if index > numberItems then
                    break
                end
                menu.items[j] = radial.items[index]
            end
            if i < numberMenus then
                menu.items[#menu.items + 1] = {
                    icon = 'fas fa-ellipsis-h',
                    label = "More",
                    menu = radial.id .. '_' .. (i + 1)
                }
            end
            menus[menu.id] = menu
        end
    else
        menus[radial.id] = radial
    end
end

---Open a registered radial submenu with the given id.
---@param id string
local function showRadial(id, transition)
    local radial = menus[id]

    if not radial then return error('No radial menu with such id found.') end

    currentRadial = radial

    -- Hide current menu and allow for transition
    if transition then
        SendNUIMessage({
            action = 'openRadialMenu',
            data = false
        })

        Wait(100)
    end

    -- If menu was closed during transition, don't open the submenu
    if isOpen == 0 then return end

    SendNUIMessage({
        action = 'openRadialMenu',
        data = {
            items = radial.items,
            sub = true
        }
    })
end

---Closes the current radial menu if it is open.
local function hideRadial()
    if isOpen == 0 then return end

    SendNUIMessage({
        action = 'openRadialMenu',
        data = false
    })

    SetNuiFocus(false, false)

    isOpen = 0
    currentRadial = nil
    table.wipe(prevMenuHistory)
    onGlobalMenu = false
end
lib.hideRadial = hideRadial

---Returns the last sub menu for the global radial.
---@return table, number
local function getLastGlobalMenu()
    local numberGlobalMenus = #globalMenus

    if numberGlobalMenus == 0 then
        globalMenus[1] = {}
        return globalMenus[1], 1
    end

    local lastGlobalMenu = globalMenus[numberGlobalMenus] or {}
    local lastMenuIndex = numberGlobalMenus
    if #lastGlobalMenu == MAX_ITEMS then
        local nextIndex = numberGlobalMenus + 1
        local menuId = GLOBL_MENU_PREFIX..nextIndex
        lastGlobalMenu[MAX_ITEMS + 1] = {
            icon = 'fas fa-ellipsis-h',
            label = 'More',
            menu = menuId
        }
        globalMenus[nextIndex] = {}
        menus[menuId] = {
            id = menuId,
            items = globalMenus[nextIndex]
        }
        lastGlobalMenu = globalMenus[nextIndex]
        lastMenuIndex = nextIndex
    end
    return lastGlobalMenu, lastMenuIndex
end

local function removeMenuFromHistory(id)
    for i = 1, #prevMenuHistory do
        if prevMenuHistory[i] == id then
            table.remove(prevMenuHistory, i)
            break
        end
    end
end

---Registers an item or array of items in the global radial menu.
---@param items RadialMenuItem | RadialMenuItem[]
function lib.addRadialItem(items)
    local invokingResource = GetInvokingResource()
    local updatedMenu = -1

    if table.type(items) == 'array' then
        for i = 1, #items do
            local item = items[i]
            local lastMenu, lastMenuIndex = getLastGlobalMenu()
            item.resource = invokingResource
            lastMenu[#lastMenu + 1] = item
            updatedMenu = lastMenuIndex
        end
    else
        items.resource = invokingResource
        local lastMenu, lastMenuIndex = getLastGlobalMenu()
        lastMenu[#lastMenu + 1] = items
        updatedMenu = lastMenuIndex
    end

    if (isOpen == updatedMenu or isOpen == updatedMenu - 1) and onGlobalMenu then
        SendNUIMessage({
            action = 'refreshItems',
            data = {items = globalMenus[isOpen]}
        })
    end
end

---Removes an item from the global radial menu with the given id.
---@param id string
local function removeRadialItem(id)
    local found = -1
    for i = 1, #globalMenus do
        local globalMenu = globalMenus[i]
        for j = 1, #globalMenu do
            local item = globalMenu[j]
            if item.id == id then
                local lastGlobalMenuIndex = #globalMenus
                local lastGlobalMenu = globalMenus[lastGlobalMenuIndex]

                local lastIndex = #lastGlobalMenu
                local lastItem = lastGlobalMenu[lastIndex]

                item.id = lastItem.id
                item.icon = lastItem.icon
                item.label = lastItem.label
                item.menu = lastItem.menu
                item.onSelect = lastItem.onSelect
                item.resource = lastItem.resource
                lastGlobalMenu[lastIndex] = nil

                if lastIndex == 1 then
                    globalMenus[lastGlobalMenuIndex] = nil
                    if lastGlobalMenuIndex > 1 then
                        globalMenus[lastGlobalMenuIndex - 1][MAX_ITEMS + 1] = nil
                        if isOpen == lastGlobalMenuIndex - 1 and onGlobalMenu then
                            SendNUIMessage({
                                action = 'refreshItems',
                                data = {items = globalMenus[isOpen]}
                            })
                        end
                        menus[GLOBL_MENU_PREFIX..lastGlobalMenuIndex] = nil

                        local temp = {}
                        for i = 1, #prevMenuHistory do
                            if prevMenuHistory[i] == GLOBL_MENU_PREFIX..lastGlobalMenuIndex then
                                break
                            end

                            temp[i] = prevMenuHistory[i]
                        end
                        table.wipe(prevMenuHistory)
                        for i = 1, #temp do
                            prevMenuHistory[i] = temp[i]
                        end
                    end
                end
                found = i
                break
            end
        end
        if found ~= -1 then break end
    end

    if isOpen == found then
        if not globalMenus[isOpen] then
            if isOpen <= 1 then
                hideRadial()
                return
            end

            isOpen = isOpen - 1
            removeMenuFromHistory(GLOBL_MENU_PREFIX..isOpen)
        end

        onGlobalMenu = true
        currentRadial = nil
        SendNUIMessage({
            action = 'refreshItems',
            data = {
                items = globalMenus[isOpen],
                sub = isOpen > 1
            }
        })
    end
end

lib.removeRadialItem = removeRadialItem

RegisterNUICallback('radialClick', function(index, cb)
    cb(1)
    local currentMenu = currentRadial or globalMenus[isOpen]
    local item = currentMenu.items and currentMenu.items[index + 1] or globalMenus[isOpen][index + 1]

    if item.menu then
        prevMenuHistory[#prevMenuHistory+1] = currentMenu.id
        if find(item.menu, GLOBL_MENU_PREFIX) then
            isOpen = isOpen + 1
            onGlobalMenu = true
        else
            onGlobalMenu = false
        end
        showRadial(item.menu, true)
    else
        hideRadial()
    end

    if item.onSelect then item.onSelect() end
end)

RegisterNUICallback('radialBack', function(_, cb)
    cb(1)
    local prevMenu = #prevMenuHistory
    if prevMenu > 0 then
        local menu = prevMenuHistory[prevMenu]
        prevMenuHistory[prevMenu] = nil
        if find(menu, GLOBL_MENU_PREFIX) then
            isOpen = isOpen - 1
            onGlobalMenu = true
        else
            onGlobalMenu = false
        end
        return showRadial(menu, false)
    end


    isOpen = 1
    onGlobalMenu = true
    currentRadial = nil

    SendNUIMessage({
        action = 'openRadialMenu',
        data = {
            items = globalMenus[isOpen]
        }
    })
end)

RegisterNUICallback('radialClose', function(_, cb)
    cb(1)

    if isOpen == 0 then return end

    SetNuiFocus(false, false)

    isOpen = 0
    currentRadial = nil
    table.wipe(prevMenuHistory)
    onGlobalMenu = false
end)

lib.addKeybind({
    name = 'ox_lib-radial',
    description = 'Open radial menu',
    defaultKey = 'z',
    onPressed = function()
        if isOpen > 0 then
            return hideRadial()
        end

        if #globalMenus == 0 or IsNuiFocused() or IsPauseMenuActive() then return end

        isOpen = 1
        onGlobalMenu = true

        SendNUIMessage({
            action = 'openRadialMenu',
            data = {
                items = globalMenus[1]
            }
        })

        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)
        SetCursorLocation(0.5, 0.5)

        while isOpen > 0 do
            DisablePlayerFiring(cache.playerId, true)
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            Wait(0)
        end
    end,
    -- onReleased = hideRadial,
})

AddEventHandler('onClientResourceStop', function(resource)
    local idsToRemove = {}

    for i = 1, #globalMenus do
        local globalMenu = globalMenus[i]
        for j = 1, #globalMenu do
            local item = globalMenu[j]
            if item.resource == resource then
                idsToRemove[#idsToRemove + 1] = item.id
            end
        end
    end

    for i = 1, #idsToRemove do
        removeRadialItem(idsToRemove[i])
    end
end)
