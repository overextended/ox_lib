local input

---@class InputDialogRowProps
---@field type 'input' | 'number' | 'checkbox' | 'select' | 'slider'
---@field label string
---@field options? { value: string, label: string, default?: string }[]
---@field password? boolean
---@field icon? string
---@field iconColor? string
---@field placeholder? string
---@field default? string | number
---@field checked? boolean
---@field min? number
---@field max? number
---@field step? number

---@param heading string
---@param rows string[] | InputDialogRowProps[]
---@return string[] | number[] | boolean[] | nil
function lib.inputDialog(heading, rows)
    if input then return end
    input = promise.new()

    -- Backwards compat with string tables
    for i = 1, #rows do
        if type(rows[i]) == 'string' then
            rows[i] = { type = 'input', label = rows[i] --[[@as string]] }
        end
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openDialog',
        data = {
            heading = heading,
            rows = rows
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
end

RegisterNUICallback('inputData', function(data, cb)
    cb(1)
    SetNuiFocus(false, false)
    local promise = input
    input = nil
    promise:resolve(data)
end)