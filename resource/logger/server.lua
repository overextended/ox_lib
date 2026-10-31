--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2026 Linden <https://github.com/thelindat>
]]

local providerName = GetConvar('ox:logger', '')

if providerName == '' then return end

local function getHostName()
    return GetConvar('ox:logger:hostname', GetConvar('sv_projectName', 'fxserver'))
        :gsub('%^%d', '')
        :gsub('%^#[%dA-Fa-f]+', '')
        :gsub('~[%a]~', '')
end

---@class OxLoggerConfig
local config = {
    hostname = getHostName(),
    jsonOptions = { indent = true, sort_keys = true }
}

---@class OxLoggerEntry
---@field level string
---@field message string
---@field metadata table<string, unknown>
---@field resource string
---@field [string] unknown

---@class OxLoggerProvider
---@field name string
---@field endpoint string
---@field headers table<string, string>
---@field status { ok: integer }
---@field append fun(log: OxLoggerEntry): table | false, string?
---@field encode fun(logs: Array): string
---@field onError fun(status: number, response: any, body: string): any?
local provider = require(('resource.logger.%s'):format(providerName))(config)

---@type Array<OxLoggerEntry>
local logs = lib.array:new()

local function badResponse(status, err)
    warn(("Failed to submit logs to %s (status: %s)\n%s"):format(provider.name, status, err))
end

local function sendLogs()
    local body = provider.encode(logs)
    table.wipe(logs)

    PerformHttpRequest(provider.endpoint, function(status, _, _, response)
        if status == provider.status.ok then return end

        local err = provider.onError(status, response, body)

        if err then
            return badResponse(status, err)
        end
    end, 'POST', body, provider.headers)
end

local function append(resource, log)
    log.metadata = log.metadata or {}
    log.metadata.resource = resource

    local result, err = provider.append(log)

    if err then
        return lib.print.error(tostring(result))
    end

    logs:push(result)
end

exports('internal_logMessage', function(resource, batch)
    if #logs == 0 then
        SetTimeout(500, sendLogs)
    end

    for i = 1, #batch do
        append(resource, batch[i])
    end
end)
