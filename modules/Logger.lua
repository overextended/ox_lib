--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2026 Linden <https://github.com/thelindat>
]]

---@meta Ox.Logger

local logs = lib.array:new()

---@param level string
---@param message string
---@param metadata? table<string, any>
local function logger(level, message, metadata)
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

return logger
