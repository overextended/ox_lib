---@param value string
function lib.setClipboard(value)
    SendNUIMessage({
        action = 'setClipboard',
        data = value
    })
end