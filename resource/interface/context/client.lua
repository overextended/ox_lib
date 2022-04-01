local contextMenus = {}

local function showContext(id)
    local data = contextMenus[id]
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showContext',
        data = {
            title = data.title,
            menu = data.menu,
            options = data.options
        }
    })
end

local function registerContext(context)
    for k, v in pairs(context) do
        if type(k) == 'number' then
            contextMenus[v.id] = v
        else
            contextMenus[context.id] = context
            break
        end
    end
end

RegisterNUICallback('openContext', function(id)
    showContext(id)
end)

RegisterNUICallback('clickContext', function(data)
    if data.event then TriggerEvent(data.event, data.args) end
    if data.serverEvent then TriggerServerEvent(data.serverEvent, data.args) end
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hideContext'
    })
end)

RegisterNUICallback('closeContext', function()
    SetNuiFocus(false, false)
end)
