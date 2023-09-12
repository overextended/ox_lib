---@class AnimOptions
---@field wait boolean
---@field speed number
---@field speedMultiplier number
---@field duration number
---@field flag number
---@field playbackRate number
---@field lockx boolean
---@field locky boolean
---@field lockz boolean

---@class AnimInstance
---@field ped number
---@field dict string
---@field anim string
---@field options AnimOptions
---@field play fun(self: AnimInstance)
---@field stop fun(self: AnimInstance)
---@field delete fun(self: AnimInstance)
---@field isPlaying fun(self: AnimInstance)

local animInstances = {}

local function playAnimation(self)
    if self.dict then
        local function handleAnimation()
            if lib.requestAnimDict(self.dict) then
                local speed = self.options.speed or 1.0
                local speedMultiplier = self.options.speedMultiplier or 1.0
                local duration = self.options.duration or 1.0
                local flag = self.options.flag or 0
                local playbackRate = self.options.playbackRate or 0
                local lockx = self.options.lockx or false
                local locky = self.options.locky or false
                local lockz = self.options.lockz or false

                TaskPlayAnim(self.ped, self.dict, self.anim, speed, speedMultiplier, duration, flag, playbackRate, lockx,
                    locky, lockz)
            end
        end

        local wait = self.options.wait or false

        if wait and duration > 1 then
            handleAnimation()
            Wait(duration)
        else
            CreateThread(handleAnimation)
        end
    else
        TaskStartScenarioInPlace(self.ped, self.anim, 0, true)
    end
end

local function checkIfPlayingAnim(self)
    return (self.dict and IsEntityPlayingAnim(self.ped, self.dict, self.anim, 3)) or
    IsPedUsingScenario(self.ped, self.anim)
end

local function stopAnimation(self)
    if self.dict then
        StopAnimTask(self.ped, self.dict, self.anim, 1.0)
        RemoveAnimDict(self.dict)
    else
        ClearPedTasks(self.ped)
    end
end

local function deleteAnimation(self)
    if self.isPlaying() then
        self.stop()
    end
    animInstances[self] = nil
end

---@param ped number
---@param dict string
---@param anim string
---@param options AnimOptions
---@return AnimInstance | nil
local function newAnimInstance(_, ped, dict, anim, options)
    if not ped or not anim or not DoesEntityExist(ped) then return end

    local self = {}

    self.ped = ped
    self.dict = dict
    self.anim = anim
    self.options = options or {}

    self.play = playAnimation
    self.stop = stopAnimation
    self.delete = deleteAnimation
    self.isPlaying = checkIfPlayingAnim

    animInstances[self] = self

    return self
end

lib.anim = setmetatable({}, {
	__call = newAnimInstance
})

function lib.anim.stopAll()
    for _, instance in pairs(animInstances) do
        instance:stop()
    end
    animInstances = {}
end

return lib.anim
