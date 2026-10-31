--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2026 Linden <https://github.com/thelindat>
]]

---@meta Ox.Logger

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
local logger = setmetatable({}, { __call = default })

function logger.error(message, metadata) return logger('error', message, metadata) end

function logger.warn(message, metadata) return logger('warn', message, metadata) end

function logger.info(message, metadata) return logger('info', message, metadata) end

function logger.verbose(message, metadata) return logger('verbose', message, metadata) end

function logger.debug(message, metadata) return logger('debug', message, metadata) end

return logger
