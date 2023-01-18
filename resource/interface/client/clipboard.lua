---@param value string
function lib.setClipboard(value)
    local is_menu_open = lib.getOpenMenu() ~= nil
    if is_menu_open then
        SendNUIMessage({
            action = 'setMenuFocus',
            data = true
        })
    end
    SendNUIMessage({
        action = 'setClipboard',
        data = value
    })
    if is_menu_open then
        SendNUIMessage({
            action = 'setMenuFocus',
            data = false
        })
    end
end