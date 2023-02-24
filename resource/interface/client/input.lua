local input
---@class InputDialogRowProps
---@field type 'input' | 'number' | 'checkbox' | 'select' | 'slider' | 'multi-select' | 'date' | 'date-range' | 'time' | 'textarea'
---@field label string
---@field options? { value: string, label: string, default?: string }[]
---@field password? boolean
---@field icon? string
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
---@field clearable? string
---@field description? string

---@class InputDialogOptionsProps
---@field allowCancel? boolean

---@param heading string
---@param rows string[] | InputDialogRowProps[]
---@param options InputDialogOptionsProps[]
---@return string[] | number[] | boolean[] | nil
local callback = function() return end
function lib.inputDialog(heading, rows, options,fn)
    if input then return end
    input = promise.new()

    -- Backwards compat with string tables
    for i = 1, #rows do
        if type(rows[i]) == 'string' then
            rows[i] = { type = 'input', label = rows[i] --[[@as string]] }
        end
    end
    if fn then
        callback = fn
    end
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openDialog',
        data = {
            heading = heading,
            rows = rows,
            options = options
        }
    })
    
    return Citizen.Await(input)
end

function lib.closeInputDialog()
    if not input then return end
    input:resolve(nil)
    input = nil
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeInputDialog'
    })
    callback = function() return end
end

RegisterNUICallback('inputData', function(data, cb)
    cb(1)
    SetNuiFocus(false, false)
    local promise = input
    input = nil
    promise:resolve(data)
    callback = function() return end
end)

RegisterNUICallback('inputCallback', function(data, cb)
    cb(1)
    callback(data)
end)