lib.cron = {}
local currentDate = os.date('*t') --[[@as osdate]]
currentDate.sec = 0

---@class OxTaskProperties
---@field minute number?
---@field hour number?
---@field day number?
---@field month number?
---@field weekday number?
---@field cb fun(task: OxTask, date: osdate)
---@field isActive boolean
---@field id number
---@field getNextTime function

---@class OxTask : OxTaskProperties
local OxTask = {}
OxTask.__index = OxTask

local maxUnits = {
    min = 60,
    hour = 24,
    wday = 7,
    day = 31,
    month = 12,
}

---@param value string | number | nil
---@param unit string
---@return string | number | false | nil
local function getTimeUnit(value, unit)
    local currentTime = currentDate[unit]

    if type(value) == 'string' then
        local unitMax = maxUnits[unit]
        local stepValue = string.match(value, '*/(%d+)')

        if stepValue then
            for i = currentTime + 1, unitMax do
                -- return the minute if it is divisible by the stepvalue
                -- i.e. */25 * * * * succeeds on :0, :25, :50
                -- could use improvements and tweaks to match cron more closely
                if i % stepValue == 0 then
                    return i
                end
            end

            return 0
        end

        local range = string.match(value, '%d+-%d+')

        if range then
            local min, max = string.strsplit('-', range)
            min, max = tonumber(min, 10), tonumber(max, 10)

            if currentTime >= min and currentTime <= max then return currentTime end

            return min
        end

        local list = string.match(value, '%d+,%d+')

        if list then
            for listValue in string.gmatch(value, '%d+') --[[@as number]] do
                listValue = tonumber(listValue)

                -- if current minute is less than in the expression 0,10,20,45 * * * *
                if listValue > currentTime then
                    return listValue
                end
            end

            -- if iterator failed, return the first value in the list
            return tonumber(string.match(value, '%d+'))
        end

        return false
    end

    return value or currentTime
end

---Get a timestamp for the next time to run the task today.
---@return number?
function OxTask:getNextTime()
    if not self.isActive then return end

    local day = getTimeUnit(self.day, 'day')

    if day ~= currentDate.day then return end

    local month = getTimeUnit(self.month, 'month')

    if month ~= currentDate.month then return end

    local weekday = getTimeUnit(self.weekday, 'wday')

    if weekday ~= currentDate.wday then return end

    local minute = getTimeUnit(self.minute, 'min')

    if not minute then return end

    local hour = getTimeUnit(self.hour, 'hour')

    if not hour then return end

    return os.time({
        min = minute < 60 and minute or 0,
        hour = hour < 24 and hour or 0,
        day = day or currentDate.day,
        month = month or currentDate.month,
        year = currentDate.year,
    })
end

---@type OxTask[]
local tasks = {}

function OxTask:scheduleTask()
    local runAt = self:getNextTime()

    if not runAt then
        return self:stop()
    end

    local currentTime = os.time()
    local sleep = runAt - currentTime

    if sleep < 0 then
        if self.day or self.weekday then
            return self:stop()
        end

        if self.hour then
            sleep += 86400
        elseif self.minute then
            sleep += 3600
        end

        if sleep < 0 then
            sleep += 60
            runAt += 60
        end
    end

    print(('running task %s in %d seconds (%0.2f minutes or %0.2f hours)'):format(self.id, sleep, sleep / 60, sleep / 60 / 60))

    if sleep > 0 then Wait(sleep * 1000) end

    if self.isActive then
        self:cb(currentDate)

        Wait(30000)

        return true
    end
end

---Start an inactive task.
function OxTask:run()
    if self.isActive then return end

    self.isActive = true

    CreateThread(function()
        while self:scheduleTask() do end
    end)
end

function OxTask:stop()
    self.isActive = false
end

---@param value string
---@return number | string | nil
local function parseCron(value, unit)
    if not value or value == '*' then return end

    if getTimeUnit(value, unit) then return value end

    return tonumber(value) or error(("syntax '%s' is not supported (only numbers and * are currently supported)"):format(value))
end

---@param expression string
---@param cb fun(task: OxTask, date: osdate)
function lib.cron.new(expression, cb)
    local minute, hour, day, month, weekday = string.strsplit(' ', expression)

    ---@type OxTask
    local task = setmetatable({
        minute = parseCron(minute, 'min'),
        hour = parseCron(hour, 'hour'),
        day = parseCron(day, 'day'),
        month = parseCron(month, 'month'),
        weekday = parseCron(weekday, 'wday'),
        cb = cb,
        id = #tasks + 1
    }, OxTask)
    tasks[task.id] = task

    task:run()
end

-- update the currentDate every minute
lib.cron.new('* * * * *', function()
    currentDate.min += 1

    if currentDate.min > 59 then
        currentDate = os.date('*t') --[[@as osdate]]
    end
end)

-- reschedule any dead tasks on a new day
lib.cron.new('0 0 * * *', function()
    for i = 1, #tasks do
        local task = tasks[i]

        if not task.isActive then
            task:run()
        end
    end
end)

return lib.cron
