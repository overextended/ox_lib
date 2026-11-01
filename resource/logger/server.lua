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

---@enum (key) OxLogLevel
local logLevel = {
    error = 1,
    warn = 2,
    info = 3,
    verbose = 4,
    debug = 5,
}

---@class OxLoggerMetadata
---@field players? number[]
---@field [string] any

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
---@field onResponse fun(status: number, response: any, body: string): boolean, string?
local provider = require(('resource.logger.%s'):format(providerName))(config)

---@type Array<OxLoggerEntry>
local logs = lib.array:new()

local function sendLogs()
    local body = provider.encode(logs)
    table.wipe(logs)

    PerformHttpRequest(provider.endpoint, function(status, _, _, response)
        local ok, err = provider.onResponse(status, response, body)

        if not ok then
            return warn(("Failed to submit logs to %s\n%s"):format(provider.name, err))
        end
    end, 'POST', body, provider.headers)
end

local players = {}

AddEventHandler('playerDropped', function()
    players[source] = nil
end)

AddEventHandler('onPlayerNameChanged', function(playerId, _, newName)
    if not players[playerId] then return end

    players[playerId].name = newName
end)

local function getPlayerInfo(playerId)
    local info = players[playerId]

    if info then return info end

    players[playerId] = {
        name = GetPlayerName(playerId)
    }

    return lib.array.reduce(GetPlayerIdentifiers(playerId), function(acc, identifier)
        local tag, value = string.strsplit(':', identifier, 2)
        acc[tag] = value

        return acc
    end, players[playerId])
end

local function append(resource, log)
    log.metadata = log.metadata or {}
    log.metadata.resource = resource

    if log.metadata.players then
        for k, v in pairs(log.metadata.players) do
            log.metadata.players[k] = getPlayerInfo(v)
        end
    end

    local result, err = provider.append(log)

    if err or not result then
        return lib.print.error(err or '')
    end

    if result.metadata and not next(result.metadata) then
        result.metadata = nil
    end

    logs:push(result)
end

exports('internal_logMessage', function(resource, batch)
    if #logs == 0 then
        SetTimeout(200, sendLogs)
    end

    for i = 1, #batch do
        append(resource, batch[i])
    end
end)
