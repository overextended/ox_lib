---@type { [string]: MenuProps }
local registeredMenus = {}
---@type MenuProps | nil
local openMenu = nil
local keepInput = IsNuiFocusKeepingInput()

---@alias MenuPosition 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right';
---@alias MenuChangeFunction fun(selected: number, scrollIndex?: number, args?: any)

---@class MenuOptions
---@field label string
---@field icon? string
---@field values? string[]
---@field description? string
---@field defaultIndex? number
---@field args? any
---@field close? boolean

---@class MenuProps
---@field id string
---@field title string
---@field options MenuOptions[]
---@field position? MenuPosition
---@field disableInput? boolean
---@field canClose? boolean
---@field onClose? fun(keyPressed?: 'Escape' | 'Backspace')
---@field onSelected? MenuChangeFunction
---@field onSideScroll? MenuChangeFunction
---@field cb? MenuChangeFunction

---@param data MenuProps
---@param cb? MenuChangeFunction
function lib.registerMenu(data, cb)
    if not data.id then error('No menu id was provided.') end
    if not data.title then error('No menu title was provided.') end
    if not data.options then error('No menu options were provided.') end
    data.cb = cb
    registeredMenus[data.id] = data
end

---@param id string
---@param startIndex? number
function lib.showMenu(id, startIndex)
    local menu = registeredMenus[id]

    if not menu then
        error(('No menu with id %s was found'):format(id))
    end

    if not openMenu then
        CreateThread(function()
            while openMenu do
                if openMenu.disableInput == nil or openMenu.disableInput then
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
            canClose = menu.canClose,
            title = menu.title,
            items = menu.options,
            startItemIndex = startIndex and startIndex - 1 or 0
        }
    })
end

local function resetFocus()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(keepInput)
end

---@param onExit boolean?
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

---@param id string
---@param options MenuOptions | MenuOptions[]
---@param index? number
function lib.setMenuOptions(id, options, index)
    if index then
        registeredMenus[id].options[index] = options
    else
        if not options[1] then error('Invalid override format used, expected table of options.') end
        registeredMenus[id].options = options
    end
end

---@return string?
function lib.getOpenMenu() return openMenu?.id end

RegisterNUICallback('confirmSelected', function(data, cb)
    cb(1)
    data[1] += 1 -- selected

    if data[2] then
        data[2] += 1 -- scrollIndex
    end

    local menu = openMenu

    if menu.options[data[1]].close ~= false then
        resetFocus()
        openMenu = nil
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
        menu.onClose(data --[[@as 'Escape' | 'Backspace' | nil]])
    end
end)
