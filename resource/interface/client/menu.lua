---@type { [string]: MenuProps }
local registeredMenus = {}
---@type MenuProps | nil
local openMenu

---@alias MenuPosition 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right'
---@alias MenuChangeFunction fun(selected: number, scrollIndex?: number, args?: any, checked?: boolean)

---@class MenuOptions
---@field label string
---@field progress? number
---@field colorScheme? string
---@field icon? string | {[1]: IconProp, [2]: string};
---@field iconColor? string
---@field values? table<string | { label: string, description: string }>
---@field checked? boolean
---@field description? string
---@field defaultIndex? number
---@field args? {[any]: any}
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
---@field onCheck? MenuChangeFunction
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
        local control = cache.game == 'fivem' and 140 or 0xE30CD707

        CreateThread(function()
            while openMenu do
                if openMenu.disableInput == nil or openMenu.disableInput then
                    DisablePlayerFiring(cache.playerId, true)
                    if cache.game == 'fivem' then
                        HudWeaponWheelIgnoreSelection()  -- Not a REDM native
                    end
                    DisableControlAction(0, control, true)
                end
                Wait(0)
            end
        end)
    end

    openMenu = menu
    lib.setNuiFocus(not menu.disableInput, true)

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
---@param onExit boolean?
function lib.hideMenu(onExit)
    local menu = openMenu
    openMenu = nil

    if not menu then return end

    lib.resetNuiFocus()

    if onExit and menu.onClose then
        menu.onClose()
    end

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
function lib.getOpenMenu() return openMenu and openMenu.id end

RegisterNUICallback('confirmSelected', function(data, cb)
    cb(1)
    data[1] += 1 -- selected

    if data[2] then
        data[2] += 1 -- scrollIndex
    end

    local menu = openMenu

    if not menu then return end

    if menu.options[data[1]].close ~= false then
        lib.resetNuiFocus()
        openMenu = nil
    end

    if menu.cb then
        menu.cb(data[1], data[2], menu.options[data[1]].args, data[3])
    end
end)

RegisterNUICallback('changeIndex', function(data, cb)
    cb(1)
    if not openMenu or not openMenu.onSideScroll then return end

    data[1] += 1 -- selected

    if data[2] then
        data[2] += 1 -- scrollIndex
    end

    openMenu.onSideScroll(data[1], data[2], openMenu.options[data[1]].args)
end)

RegisterNUICallback('changeSelected', function(data, cb)
    cb(1)
    if not openMenu or not openMenu.onSelected then return end

    data[1] += 1 -- selected


    local args = openMenu.options[data[1]].args

    if args and type(args) ~= 'table' then
        return error("Menu args must be passed as a table")
    end

    if not args then args = {} end
    if data[2] then args[data[3]] = true end

    if data[2] and not args.isCheck then
        data[2] += 1 -- scrollIndex
    end

    openMenu.onSelected(data[1], data[2], args)
end)

RegisterNUICallback('changeChecked', function(data, cb)
    cb(1)
    if not openMenu or not openMenu.onCheck then return end

    data[1] += 1 -- selected

    openMenu.onCheck(data[1], data[2], openMenu.options[data[1]].args)
end)

RegisterNUICallback('closeMenu', function(data, cb)
    cb(1)
    lib.resetNuiFocus()

    local menu = openMenu

    if not menu then return end

    openMenu = nil

    if menu.onClose then
        menu.onClose(data --[[@as 'Escape' | 'Backspace' | nil]])
    end
end)
