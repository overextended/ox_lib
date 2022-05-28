local contextMenus = {}
local openContextMenu = nil

function lib.showContext(id)
    if not contextMenus[id] then return error('No context menu of such id found.') end
    local data = contextMenus[id]
    openContextMenu = id
    SetNuiFocus(true, true)
    SendNuiMessage(json.encode({
        action = 'showContext',
        data = {
            title = data.title,
            menu = data.menu,
            options = data.options
        }
    }, { sort_keys = true }))
end

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

function lib.getOpenContextMenu() return openContextMenu end

RegisterNUICallback('openContext', function(id, cb)
    cb(1)
    lib.showContext(id)
end)

RegisterNUICallback('clickContext', function(id, cb)
    cb(1)
    SetNuiFocus(false, false)
    local data = contextMenus[openContextMenu].options[id]
    if data.event then TriggerEvent(data.event, data.args) end
    if data.serverEvent then TriggerServerEvent(data.serverEvent, data.args) end

    openContextMenu = nil
    SendNUIMessage({
        action = 'hideContext'
    })
end)

RegisterNUICallback('closeContext', function(_, cb)
    cb(1)
    SetNuiFocus(false, false)
end)
