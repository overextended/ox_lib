--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@alias IconProp 'fas' | 'far' | 'fal' | 'fat' | 'fad' | 'fab' | 'fak' | 'fass'

local keepInput = IsNuiFocusKeepingInput()
local hasFocus = false

function lib.setNuiFocus(allowInput, disableCursor)
    -- Only snapshot keep-input on the first acquisition, so a nested UI can't overwrite it.
    if not hasFocus then
        keepInput = IsNuiFocusKeepingInput()
        hasFocus = true
    end

    SetNuiFocus(true, not disableCursor)
    SetNuiFocusKeepInput(allowInput)
end

function lib.resetNuiFocus()
    hasFocus = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(keepInput)
end
