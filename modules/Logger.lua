--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2026 Linden <https://github.com/thelindat>
]]

---@meta Ox.Logger

---@type Array<OxLoggerEntry>
local logs = lib.array:new()

---@param level OxLogLevel
---@param message string
---@param metadata? table<string, any>
local function default(level, message, metadata)
    if #logs == 0 then
        SetTimeout(50, function()
            exports.ox_lib:internal_logMessage(cache.resource, logs)
            table.wipe(logs)
        end)
    end

    logs:push({
        level = level,
        message = message,
        metadata = metadata
    })
end

---@overload fun(level: OxLogLevel, message: string, metadata?: table<string, any>)
local logger = setmetatable({}, {
    __call = function(...) return default(...) end
})

---@param message string
---@param metadata? OxLoggerMetadata
function logger.error(message, metadata) return default('error', message, metadata) end

---@param message string
---@param metadata? OxLoggerMetadata
function logger.warn(message, metadata) return default('warn', message, metadata) end

---@param message string
---@param metadata? OxLoggerMetadata
function logger.info(message, metadata) return default('info', message, metadata) end

---@param message string
---@param metadata? OxLoggerMetadata
function logger.verbose(message, metadata) return default('verbose', message, metadata) end

---@param message string
---@param metadata? OxLoggerMetadata
function logger.debug(message, metadata) return default('debug', message, metadata) end

return default
