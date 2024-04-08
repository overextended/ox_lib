---@class TimerPrivateProps
---@field onEnd? fun() cb function triggered when the timer finishes
---@field async? boolean wether the timer should run asynchronously or not
---@field startTime number the gametimer stamp of when the timer starts. changes when paused and played
---@field triggerOnEnd boolean set in the forceEnd method using the optional param. wether or not the onEnd function is triggered when force ending the timer early
---@field currentTime number current timer length
---@field tickActive boolean or not the tick is running

---@class CTimer : OxClass
---@field private TimerPrivateProps
---@field constructor fun(self: self, time: number, onEnd: fun(), async: boolean)
---@field start fun(self: self) starts the timer
---@field tick fun(self: self) handles the tick of the timer. not for use externally
---@field forceEnd fun(self: self, triggerOnEnd: boolean) end timer early and optionally trigger the onEnd function still
---@field pause fun(self: self) pauses the timer until play method is called
---@field play fun(self: self) resumes the timer if paused
---@field getTimeLeft fun(self: self): number returns the time left on the timer in milliseconds
local timer = lib.class('CTimer')

function timer:constructor(time, onEnd, async)
    assert(type(time) == "number" and time > 0, "Time must be a positive number")
    assert(onEnd == nil or type(onEnd) == "function", "onEnd must be a function or nil")
    assert(type(async) == "boolean" or async == nil, "async must be a boolean or nil")

    self.time = time
    self.paused = false

    self.private.currentTime = time
    self.private.onEnd = onEnd
    self.private.async = async
    self.private.startTime = 0
    self.private.triggerOnEnd = true

    self:start()
end

function timer:start()
    if self.private.startTime > 0 then return end

    self.private.startTime = GetGameTimer()

    if self.private.async then
        CreateThread(function()
            self:tick()
        end)
    else
        self:tick()
    end
end

function timer:tick()
    if not debug.getinfo(2, 'S').short_src:find('@ox_lib/imports/timer') then
        lib.print.warn('the tick method is only called interally')
        return
    end

    self.private.tickActive = true

    while true do
        if self.paused then
            while self.paused do
                Wait(0)
            end
        end

        if GetGameTimer() - self.private.startTime >= self.private.currentTime then
            break
        end

        Wait(0)
    end

    self.private.tickActive = false

    if self.private.triggerOnEnd and self.private.onEnd then
        self.private:onEnd()
    end
end

function timer:forceEnd(triggerOnEnd)
    self.private.triggerOnEnd = triggerOnEnd
    self.private.currentTime = 0
end

function timer:pause()
    if self.paused then return end
    self.private.currentTime = self:getTimeLeft()
    self.paused = true
end

function timer:play()
    if not self.paused then return end
    self.private.startTime = GetGameTimer()
    self.paused = false
end

function timer:restart()
    self.private.startTime = 0
    self:start()
end

function timer:getTimeLeft()
    return self.private.currentTime - (GetGameTimer() - self.private.startTime)
end

lib.timer = {
    async = function(time, onEnd)
        return timer:new(time, onEnd, true)
    end
}

setmetatable(lib.timer, {
    __call = function(t, time, onEnd)
        return timer:new(time, onEnd)
    end
})

return lib.timer
