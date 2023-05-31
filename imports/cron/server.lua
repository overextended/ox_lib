lib.cron = {}
local currentDate = os.date('*t') --[[@as osdate]]
currentDate.sec = 0

---@class OxTaskProperties
---@field minute? number | string
---@field hour? number | string
---@field day? number | string
---@field month? number | string
---@field weekday? number | string
---@field job fun(task: OxTask, date: osdate)
---@field isActive boolean
---@field id number
---@field debug? boolean

---@class OxTask : OxTaskProperties
---@field private scheduleTask fun(self: OxTask): boolean?
local OxTask = {}
OxTask.__index = OxTask

local maxUnits = {
    min = 60,
    hour = 24,
    wday = 7,
    day = 31,
    month = 12,
}

--- Gets the amount of days in certain month
---@param month number
---@param year? number
---@return number
local function getMaxDaysInMonth(month, year)
    year = year or currentDate.year
    local nextMonth = month + 1
    local nextMonthFirstDay = os.time{year=year, month=nextMonth, day=1}
    local lastDayOfCurrentMonth = os.date("%d", nextMonthFirstDay - 86400)
    return tonumber(lastDayOfCurrentMonth)
end

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
                -- return the current minute if it is divisible by the stepvalue
                -- i.e. */10 * * * * is equal to a list of 0,10,20,30,40,50
                -- best suited to numbers evenly divided by unitMax
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
    
    -- If current day is the last day of the month, and the task is scheduled for the last day of the month, then the task should run.
    if day == 0 then
        -- Should probably be used month from getTimeUnit, but don't want to reorder this code.
        day = getMaxDaysInMonth(currentDate.month)
    end

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

-- Get timestamp for next time to run task at any day.
---@return number
function OxTask:getAbsoluteNextTime()
    local minute = getTimeUnit(self.minute, 'min')

    local hour = getTimeUnit(self.hour, 'hour')

    local day = getTimeUnit(self.day, 'day')
    
    local month = getTimeUnit(self.month, 'month')

    local year = getTimeUnit(self.year, 'year')

    -- To avoid modifying getTimeUnit function, the day is adjusted here if needed.
    if self.day then
        if currentDate.hour < hour or (currentDate.hour == hour and currentDate.min < minute) then
            day = day - 1
            if day < 1 then
                day = getMaxDaysInMonth(currentDate.month)
            end
        end 
        if currentDate.hour > hour or (currentDate.hour == hour and currentDate.min >= minute) then
            day = day + 1
            if day > getMaxDaysInMonth(currentDate.month) or day == 1 then
                day = 1
                month = month + 1
            end
        end
    end

    -- Check if time will be in next year.
    if os.time({year=year, month=month, day=day, hour=hour, min=minute}) < os.time() then
        year = year and year + 1 or currentDate.year + 1
    end

    return os.time({
        min = minute < 60 and minute or 0,
        hour = hour < 24 and hour or 0,
        day = day or currentDate.day,
        month = month or currentDate.month,
        year = year or currentDate.year,
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

    if self.debug then
        print(('running task %s in %d seconds (%0.2f minutes or %0.2f hours)'):format(self.id, sleep, sleep / 60, sleep / 60 / 60))
    end

    if sleep > 0 then Wait(sleep * 1000) end

    if self.isActive then
        self:job(currentDate)

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
    if self.debug then
        print(('stopping task %s'):format(self.id))
    end

    self.isActive = false
end

---@param value string
---@return number | string | nil
local function parseCron(value, unit)
    if not value or value == '*' then return end

    local num = tonumber(value)

    if num then return num end

    if unit == 'wday' then
        if value == 'sun' then return 1 end
        if value == 'mon' then return 2 end
        if value == 'tue' then return 3 end
        if value == 'wed' then return 4 end
        if value == 'thu' then return 5 end
        if value == 'fri' then return 6 end
        if value == 'sat' then return 7 end
    end

    if unit == 'month' then
        if value == 'jan' then return 1 end
        if value == 'feb' then return 2 end
        if value == 'mar' then return 3 end
        if value == 'apr' then return 4 end
        if value == 'may' then return 5 end
        if value == 'jun' then return 6 end
        if value == 'jul' then return 7 end
        if value == 'aug' then return 8 end
        if value == 'sep' then return 9 end
        if value == 'oct' then return 10 end
        if value == 'nov' then return 11 end
        if value == 'dec' then return 12 end
    end

    if getTimeUnit(value, unit) then return value end

    error(("^1invalid cron expression. '%s' is not supported for %s^0"):format(value, unit), 3)
end

---@param expression string A cron expression such as `* * * * *` representing minute, hour, day, month, and day of the week.
---@param job fun(task: OxTask, date: osdate)
---@param options? { debug?: boolean }
---Creates a new [cronjob](https://en.wikipedia.org/wiki/Cron), scheduling a task to run at fixed times or intervals.  
---Supports numbers, any value `*`, lists `1,2,3`, ranges `1-3`, and steps `*/4`.  
---Day of the week is a range of `1-7` starting from Sunday and allows short-names (i.e. sun, mon, tue).
function lib.cron.new(expression, job, options)
    if not job or type(job) ~= 'function' then return end

    local minute, hour, day, month, weekday = string.strsplit(' ', string.lower(expression))
    ---@type OxTask
    local task = setmetatable(options or {}, OxTask)

    task.minute = parseCron(minute, 'min')
    task.hour = parseCron(hour, 'hour')
    task.day = parseCron(day, 'day')
    task.month = parseCron(month, 'month')
    task.weekday = parseCron(weekday, 'wday')
    task.id = #tasks + 1
    task.job = job
    tasks[task.id] = task
    task:run()

    return task
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
