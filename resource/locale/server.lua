--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

function lib.getLocaleKey()
    return GetConvar('ox:locale', Config.Locale or 'en')
end

lib.locale(lib.getLocaleKey())
