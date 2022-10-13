---@class CKeybind
---@field name string
---@field category string
---@field description string
---@field keybind string
---@field disabled boolean
---@field disable? fun(self: CKeybind, toggle: boolean)
---@field onPressed? fun(self: CKeybind)
---@field onReleased? fun(self: CKeybind)

local keybinds = {}

local function disableKeybind(self, toggle)
    keybinds[self.name].disabled = toggle
end

lib.keybinds = {
    ---@return CKeybind
    new = function(self)
        self.keybind = self.keybind or ''
        self.disabled = self.disabled or false
        self.disable = disableKeybind
    
        RegisterCommand('+'..self.name, function()
            if IsPauseMenuActive() then return end
            if keybinds[self.name].disabled then return end
            if self.onPressed then self:onPressed() end
        end)
    
        RegisterCommand('-'..self.name, function()
            if IsPauseMenuActive() then return end
            if keybinds[self.name].disabled then return end
            if self.onReleased then self:onReleased() end
        end)
    
        RegisterKeyMapping('+'..self.name, self.description, 'keyboard', self.keybind)
        TriggerEvent('chat:removeSuggestion', ('/+%s'):format(self.name))
        TriggerEvent('chat:removeSuggestion', ('/-%s'):format(self.name))
        return self
    end,

    ---@return CKeybind | false
    get = function(name)
        if not keybinds[name] then return false end
        return keybinds[name]
    end
}

return lib.keybinds