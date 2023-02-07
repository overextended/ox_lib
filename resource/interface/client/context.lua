local contextMenus = {}
local lastHoveredContextItem = nil
local openContextMenu = nil
local keepInput = IsNuiFocusKeepingInput()

---@class ContextMenuItem
---@field title? string
---@field menu? string
---@field icon? string
---@field iconColor? string
---@field onSelect? fun(args: any)
---@field onHover? fun(hoverState: boolean, args: any)
---@field arrow? boolean
---@field description? string
---@field metadata? string | { [string]: any } | string[]
---@field disabled? boolean
---@field event? string
---@field serverEvent? string
---@field args? any

---@class ContextMenuArrayItem : ContextMenuItem
---@field title string

---@class ContextMenuProps
---@field id string
---@field title string
---@field menu? string
---@field onExit? fun()
---@field onBack? fun()
---@field canClose? boolean
---@field options { [string]: ContextMenuItem } | ContextMenuArrayItem[]

local function resetFocus()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(keepInput)
end

local function closeContext(_, cb, onExit)
    if cb then cb(1) end
    if (cb or onExit) and contextMenus[openContextMenu].onExit then contextMenus[openContextMenu].onExit() end

    resetFocus()

    if not cb then SendNUIMessage({ action = 'hideContext' }) end

    if lastHoveredContextItem then
        local data = contextMenus[openContextMenu].options[lastHoveredContextItem]
        if data.onHover then data.onHover(false, data.args) end
        lastHoveredContextItem = nil
    end

    openContextMenu = nil
end

local function checkID(id) 
    if math.type(tonumber(id)) == 'float' then
        id = math.tointeger(id)
    elseif tonumber(id) then
        id += 1
    end

    return id
end

---@param id string
function lib.showContext(id)
    if not contextMenus[id] then error('No context menu of such id found.') end
    local data = contextMenus[id]
    openContextMenu = id
    keepInput = IsNuiFocusKeepingInput()

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    SendNuiMessage(json.encode({
        action = 'showContext',
        data = {
            title = data.title,
            canClose = data.canClose,
            menu = data.menu,
            options = data.options
        }
    }, { sort_keys = true }))
end

---@param context ContextMenuProps | ContextMenuProps[]
function lib.registerContext(context)
    for k, v in pairs(context) do
        if type(k) == 'number' then
            contextMenus[v.id] = v
        else
            contextMenus[context.id] = context
            break
        end
    end
end

---@return string?
function lib.getOpenContextMenu() return openContextMenu end

---@param onExit boolean?
function lib.hideContext(onExit) closeContext(nil, nil, onExit) end

RegisterNUICallback('openContext', function(data, cb)
    if data.back and contextMenus[openContextMenu].onBack then contextMenus[openContextMenu].onBack() end
    cb(1)
    lib.showContext(data.id)
end)


RegisterNUICallback('clickContext', function(id, cb)
    cb(1)

    local id = checkID(id)

    local data = contextMenus[openContextMenu].options[id]

    if not data.event and not data.serverEvent and not data.onSelect then return end

    openContextMenu = nil

    resetFocus()

    if data.onSelect then data.onSelect(data.args) end
    if data.event then TriggerEvent(data.event, data.args) end
    if data.serverEvent then TriggerServerEvent(data.serverEvent, data.args) end

    if lastHoveredContextItem then
        local data = contextMenus[openContextMenu].options[lastHoveredContextItem]
        if data.onHover then data.onHover(false, data.args) end
        lastHoveredContextItem = nil
    end

    SendNUIMessage({
        action = 'hideContext'
    })
end)

RegisterNUICallback('onHover', function(data, cb)
    cb(1)

    local id = checkID(data.id)
    local hoverState = data.hoverState

    local data = contextMenus[openContextMenu].options[id]

    if not data.onHover then return end

    if data.onHover and hoverState == true then
        lastHoveredContextItem = id
        data.onHover(true, data.args)
    end
    if data.onHover and hoverState == false then
        lastHoveredContextItem = nil
        data.onHover(false, data.args)
    end
end)

RegisterNUICallback('closeContext', closeContext)
