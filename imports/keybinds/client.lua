---@class CKeybind
---@field name string
---@field description string
---@field keybind string
---@field disabled? boolean
---@field disable? fun(self: CKeybind, toggle: boolean)
---@field onPressed? fun(self: CKeybind)
---@field onReleased? fun(self: CKeybind)

local keybinds = {}

local function disableKeybind(self, toggle)
    keybinds[self.name].disabled = toggle
end

local IsPauseMenuActive = IsPauseMenuActive

lib.keybinds = {
    ---@param data CKeybind
    ---@return CKeybind
    new = function(data)
        data.keybind = data.keybind or ''
        data.disabled = data.disabled or false
        data.disable = disableKeybind

        RegisterCommand('+' .. data.name, function()
            if not data.onReleased or data.disabled or IsPauseMenuActive() then return end
            data:onPressed()
        end)

        RegisterCommand('-' .. data.name, function()
            if not data.onReleased or data.disabled or IsPauseMenuActive() then return end
            data:onReleased()
        end)

        RegisterKeyMapping('+' .. data.name, data.description, 'keyboard', data.keybind)

        SetTimeout(500, function()
            TriggerEvent('chat:removeSuggestion', ('/+%s'):format(data.name))
            TriggerEvent('chat:removeSuggestion', ('/-%s'):format(data.name))
        end)

        keybinds[data.name] = data
        return data
    end,

    ---@return CKeybind?
    get = function(name)
        return keybinds[name]
    end
}

return lib.keybinds
