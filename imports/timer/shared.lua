---@class CTimer : OxClass
local timer = lib.class('CTimer')

---@param time number
---@param onEnd? fun(data: CTimer)
---@param async? boolean
function timer:constructor(time, onEnd, async)
    if not time then
        return lib.print.error('No time was provided to the timer')
    end

    self.time = time
    self.paused = false

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
    if not debug.getinfo(2, 'S').short_src:find('@ox_lib/imports/timer') then lib.print.warn('the tick method is only called interally') return end

    while true do
        if self.paused then
            self.time -= (GetGameTimer() - self.private.startTime)
            while self.paused do
                Wait(0)
            end
            self.private.startTime = GetGameTimer()
        end
        if GetGameTimer() - self.private.startTime >= self.time then
            break
        end
        Wait(0)
    end
    if self.private.triggerOnEnd and self.private.onEnd then
        self.private:onEnd()
    end

    self = nil
end

function timer:forceEnd(triggerOnEnd)
    self.private.triggerOnEnd = triggerOnEnd
    self.time = 0
end

function timer:pause()
    if self.paused then return end
    self.paused = true
end

function timer:play()
    if not self.paused then return end
    self.paused = false
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
