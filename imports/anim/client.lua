---@class AnimProperties
---@field ped number
---@field dict string
---@field anim string
---@field options table

---@class AnimInstance : AnimProperties
---@field stop fun()

local animInstances = {}

local function stopAnimation(self)
    if self.dict then
        StopAnimTask(self.ped, self.dict, self.anim, 1.0)
        RemoveAnimDict(self.dict)
    else
        ClearPedTasks(self.ped)
    end
end

local function startAnimation(ped, dict, anim, options)
    local self = setmetatable({}, { __index = AnimProperties })

    self.ped = ped
    self.dict = dict
    self.anim = anim
    self.options = options or {}

    if dict then
        CreateThread(function()
            lib.requestAnimDict(dict)

            local speed = self.options.speed or 1.0
            local speedMultiplier = self.options.speedMultiplier or 1.0
            local duration = self.options.duration or 1.0
            local flag = self.options.flag or 0
            local playbackRate = self.options.playbackRate or 0
            local lockx = self.options.lockx or false
            local locky = self.options.locky or false
            local lockz = self.options.lockz or false

            TaskPlayAnim(self.ped, dict, anim, speed, speedMultiplier, duration, flag, playbackRate, lockx, locky, lockz)
        end)
    else
        TaskStartScenarioInPlace(self.ped, anim, 0, true)
    end

    self.stop = stopAnimation

    table.insert(animInstances, self)

    return self
end

lib.anim = {
    new = startAnimation,
    stopAll = function()
        for _, instance in ipairs(animInstances) do
            instance:stop()
        end
    end,
    getAllInstances = function()
        return animInstances
    end
}

return lib.anim
