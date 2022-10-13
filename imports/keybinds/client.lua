---@class CKeybind
---@field name string
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
        
        keybinds[self.name] = self
        return self
    end,

    ---@return CKeybind | false
    get = function(name)
        return keybinds[name] or false
    end
}

return lib.keybinds