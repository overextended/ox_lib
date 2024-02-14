---@type table<string, number>
local Cooldowns = {}

CreateThread(function ()
    while true do
        Wait(0)
        for key, endTime in pairs(Cooldowns) do
            if endTime < GetGameTimer() then
                Cooldowns[key] = nil
            end
        end
    end
end)

lib.cooldown = setmetatable({
    getRemainingTime = function (key)
        if not Cooldowns[key] then return 0 end
        return Cooldowns[key] and (Cooldowns[key] - GetGameTimer()) or 0
    end
}, {
    __index = function (self, key)
        return Cooldowns[key] ~= nil
    end,
    __newindex = function (self, key, value)
        if type(value) ~= "number" then lib.print.error("value must be a number") end
        if Cooldowns[key] then lib.print.warn(("cooldown '%s' already exists, overwriting it."):format(key)) end

        Cooldowns[key] = GetGameTimer() + value
    end
})

return lib.cooldown