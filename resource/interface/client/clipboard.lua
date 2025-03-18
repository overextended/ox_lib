--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright (c) 2025 Linden <https://github.com/thelindat/fivem>
]]

---@param value string
function lib.setClipboard(value)
    SendNUIMessage({
        action = 'setClipboard',
        data = value
    })
end
