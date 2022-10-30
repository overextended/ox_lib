---@class KeybindProps
---@field name string
---@field description string
---@field defaultKey? string
---@field disabled? boolean
---@field disable? fun(self: CKeybind, toggle: boolean)
---@field onPressed? fun(self: CKeybind)
---@field onReleased? fun(self: CKeybind)
---@field [string] any

---@class CKeybind : KeybindProps
---@field currentKey string

local keybinds = {}

local function disableKeybind(self, toggle)
    keybinds[self.name].disabled = toggle
end

local IsPauseMenuActive = IsPauseMenuActive

---@param data KeybindProps
---@return CKeybind
function lib.addKeybind(data)
    if not data.defaultKey then data.defaultKey = '' end
    local command = data.name
    if data.onReleased then command = ('+%s'):format(data.name) end

    if not data.onPressed then 
        error('expected onPressed function for table (received nil)')
        return 
    end

    RegisterCommand(command, function()
        if data.disabled or IsPauseMenuActive() then return end
        data:onPressed()
    end)

    if data.onReleased then
        RegisterCommand('-' .. data.name, function()
            if data.disabled or IsPauseMenuActive() then return end
            data:onReleased()
        end) 
    end

    RegisterKeyMapping(command, data.description, 'keyboard', data.defaultKey)

    SetTimeout(500, function()
        TriggerEvent('chat:removeSuggestion', ('/%s'):format(command))
        TriggerEvent('chat:removeSuggestion', ('/-%s'):format(data.name))
    end)

    data.currentKey = GetControlInstructionalButton(0, joaat(command) | 0x80000000, 1):sub(3)
    data.disabled = data.disabled or false
    data.disable = disableKeybind
    keybinds[data.name] = data
    ---@cast data -KeybindProps
    return data
end

return lib.addKeybind
