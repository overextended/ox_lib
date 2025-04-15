--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local input, inputData

---@class InputDialogRowProps
---@field type 'input' | 'number' | 'checkbox' | 'select' | 'slider' | 'multi-select' | 'date' | 'date-range' | 'time' | 'textarea' | 'color'
---@field label string
---@field options? { value: string, label: string, default?: string }[]
---@field password? boolean
---@field icon? string | {[1]: IconProp, [2]: string}
---@field iconColor? string
---@field placeholder? string
---@field default? string | number
---@field disabled? boolean
---@field checked? boolean
---@field min? number
---@field max? number
---@field step? number
---@field autosize? boolean
---@field required? boolean
---@field format? string
---@field returnString? boolean
---@field clearable? boolean
---@field searchable? boolean
---@field description? string
---@field maxSelectedValues? number

---@class InputDialogOptionsProps
---@field allowCancel? boolean

---@param heading string
---@param rows string[] | InputDialogRowProps[]
---@param options InputDialogOptionsProps[]?
---@return string[] | number[] | boolean[] | nil
function lib.inputDialog(heading, rows, options)
    if input then return end
    input = promise.new()
    inputData = { heading = heading, rows = rows, options = options }

    -- Backwards compat with string tables
    for i = 1, #rows do
        if type(rows[i]) == 'string' then
            rows[i] = { type = 'input', label = rows[i] --[[@as string]] }
        end
    end

    lib.setNuiFocus(false)
    SendNUIMessage({ action = 'openDialog', data = inputData })

    return input:await()
end

function lib.getOpenInputDialog()
    return input ~= nil, inputData
end

function lib.closeInputDialog()
    if not input then return end

    lib.resetNuiFocus()
    SendNUIMessage({
        action = 'closeInputDialog'
    })
    
    input:resolve(nil)
    input, inputData = nil, nil
end

RegisterNUICallback('inputData', function(data, cb)
    cb(1)
    lib.resetNuiFocus()
    
    local promise = input
    input, inputData = nil, nil
    promise:resolve(data)
end)
