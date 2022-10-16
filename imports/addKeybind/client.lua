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
    data.defaultKey = data.defaultKey or ''
    data.currentKey = GetControlInstructionalButton(0, joaat('+' .. data.name) | 0x80000000, true):sub(3)
    data.disabled = data.disabled or false
    data.disable = disableKeybind

    RegisterCommand('+' .. data.name, function()
        if not data.onPressed or data.disabled or IsPauseMenuActive() then return end
        data:onPressed()
    end)

    RegisterCommand('-' .. data.name, function()
        if not data.onReleased or data.disabled or IsPauseMenuActive() then return end
        data:onReleased()
    end)

    RegisterKeyMapping('+' .. data.name, data.description, 'keyboard', data.defaultKey)

    SetTimeout(500, function()
        TriggerEvent('chat:removeSuggestion', ('/+%s'):format(data.name))
        TriggerEvent('chat:removeSuggestion', ('/-%s'):format(data.name))
    end)

    keybinds[data.name] = data
    ---@cast data -KeybindProps
    return data
end

return lib.addKeybind
