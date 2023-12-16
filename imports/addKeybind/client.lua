if cache.game == 'redm' then return end

---@class KeybindProps
---@field name string
---@field description string
---@field defaultMapper? string (see: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/)
---@field defaultKey? string
---@field disabled? boolean
---@field disable? fun(self: CKeybind, toggle: boolean)
---@field onPressed? fun(self: CKeybind)
---@field onReleased? fun(self: CKeybind)
---@field [string] any

---@class CKeybind : KeybindProps
---@field currentKey string
---@field disabled boolean
---@field hash number
---@field getCurrentKey fun(): string

local keybinds = {}

local IsPauseMenuActive = IsPauseMenuActive
local GetControlInstructionalButton = GetControlInstructionalButton

local keybind_mt = {
    disabled = false,
    defaultKey = '',
    defaultMapper = 'keyboard',
}

function keybind_mt:__index(index)
    return index == 'currentKey' and self:getCurrentKey() or keybind_mt[index]
end

function keybind_mt:getCurrentKey()
    return GetControlInstructionalButton(0, self.hash, true):sub(3)
end

function keybind_mt:disable(toggle)
    self.disabled = toggle
end

---@param data KeybindProps
---@return CKeybind
function lib.addKeybind(data)
    ---@cast data CKeybind
    data.hash = joaat('+' .. data.name) | 0x80000000
    keybinds[data.name] = setmetatable(data, keybind_mt)

    RegisterCommand('+' .. data.name, function()
        if not data.onPressed or data.disabled or IsPauseMenuActive() then return end
        data:onPressed()
    end)

    RegisterCommand('-' .. data.name, function()
        if not data.onReleased or data.disabled or IsPauseMenuActive() then return end
        data:onReleased()
    end)

    RegisterKeyMapping('+' .. data.name, data.description, data.defaultMapper, data.defaultKey)

    if data.secondaryKey then
        RegisterKeyMapping('~!+' .. data.name, data.description, data.secondaryMapper or data.defaultMapper, data.secondaryKey)
    end

    SetTimeout(500, function()
        TriggerEvent('chat:removeSuggestion', ('/+%s'):format(data.name))
        TriggerEvent('chat:removeSuggestion', ('/-%s'):format(data.name))
    end)

    return data
end

return lib.addKeybind
