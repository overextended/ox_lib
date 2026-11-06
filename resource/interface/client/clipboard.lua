--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@param value string
function lib.setClipboard(value)
    if IsNuiFocused() then
        return SendNUIMessage({ action = 'setClipboard', data = value })
    end

    -- The copy only works while the NUI page has focus (FiveM's frames block the Clipboard API), so focus it for a
    -- moment while keeping game input. Focus arrives asynchronously, so wait before copying and release afterwards.
    CreateThread(function()
        local keepInput = IsNuiFocusKeepingInput()
        SetNuiFocus(true, false)
        SetNuiFocusKeepInput(true)
        Wait(50)
        SendNUIMessage({ action = 'setClipboard', data = value })
        Wait(300)
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(keepInput)
    end)
end
