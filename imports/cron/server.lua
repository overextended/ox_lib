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

---Get a timestamp for the next time to run the task today.
---@return number?
function OxTask:getNextTime()
    if not self.isActive then return end
    if self.day and self.day ~= currentDate.day then return end
    if self.month and self.month ~= currentDate.month then return end
    if self.weekday and self.weekday ~= currentDate.wday then return end

    return os.time({
        hour = self.hour or currentDate.hour,
        min = self.minute or currentDate.min,
        year = currentDate.year,
        month = self.month or currentDate.month,
        day = self.day or currentDate.day,
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

        Wait(60000)

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
---@return number | nil
---@todo support proper cron expressions (lists, ranges, step values)
---@todo "*/5 * * * *" to run every 5 minutes would be cool
local function parseCron(value)
    if not value or value == '*' then return end

    return tonumber(value) or error(("syntax '%s' is not supported (only numbers and * are currently supported)"):format(value))
end

---@param expression string
---@param cb fun(task: OxTask, date: osdate)
function lib.cron.new(expression, cb)
    local minute, hour, day, month, weekday = string.strsplit(' ', expression)

    ---@type OxTask
    local task = setmetatable({
        minute = parseCron(minute),
        hour = parseCron(hour),
        day = parseCron(day),
        month = parseCron(month),
        weekday = parseCron(weekday),
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
