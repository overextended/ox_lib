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

local function disableKeybind(self, toggle)
    keybinds[self.name].disabled = toggle
end

local IsPauseMenuActive = IsPauseMenuActive
local GetControlInstructionalButton = GetControlInstructionalButton

local keybind_mt = {
    disabled = false,
}

function keybind_mt:__index(index)
    local value = keybind_mt[index]

    if value then
        return value
    end

    if index == 'currentKey' then
        return self:getCurrentKey()
    end
end

function keybind_mt:getCurrentKey()
    return GetControlInstructionalButton(0, self.hash, true):sub(3)
end

---@param data KeybindProps
---@return CKeybind
function lib.addKeybind(data)
    if not data.defaultKey then data.defaultKey = '' end
    if not data.defaultMapper then data.defaultMapper = 'keyboard' end

    RegisterCommand('+' .. data.name, function()
        if not data.onPressed or data.disabled or IsPauseMenuActive() then return end
        data:onPressed()
    end)

    RegisterCommand('-' .. data.name, function()
        if not data.onReleased or data.disabled or IsPauseMenuActive() then return end
        data:onReleased()
    end)

    RegisterKeyMapping('+' .. data.name, data.description, data.defaultMapper, data.defaultKey)

    SetTimeout(500, function()
        TriggerEvent('chat:removeSuggestion', ('/+%s'):format(data.name))
        TriggerEvent('chat:removeSuggestion', ('/-%s'):format(data.name))
    end)

    data.hash = joaat('+' .. data.name) | 0x80000000
    data.disabled = data.disabled
    data.disable = disableKeybind
    keybinds[data.name] = setmetatable(data, keybind_mt)

    return data --[[@as CKeybind]]
end

return lib.addKeybind
