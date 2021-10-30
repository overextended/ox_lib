if not _VERSION:find('5.4') then
    error('^1Lua 5.4 must be enabled in the resource manifest!^0', 0)
end

local LIBRARY  = 'library'
local SERVICE  = IsDuplicityVersion() and 'server' or 'client'
local RESOURCE = GetCurrentResourceName()

local MODULES = {}
local IMPORTS = {}

local function LoadModule(file, import)
    if (import and not IMPORTS[file]) or (not import and not MODULES[file]) then
        file = import and ('imports/%s'):format(file) or file
        local chunk = LoadResourceFile(import or RESOURCE, ('%s/%s.lua'):format(file, SERVICE))
        local shared = LoadResourceFile(import or RESOURCE, ('%s/shared.lua'):format(file))
        if shared then
            chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
        end
        if chunk then
            chunk, err = load(chunk, ('@@%s.lua'):format(SERVICE), 't')
            if err then
                error(('\n^1Error loading module (%s): %s^0'):format(file, err), 0)
            else
                if import then IMPORTS[file] = chunk() else MODULES[file] = chunk() end
            end
        else error(('\n^3Unable to load module (%s)^0'):format(file), 0) end
    end
    return (import and IMPORTS[file]) or MODULES[file]
end

---Loads a module from within the current resource.
---If the module has already been loaded then it will reference the existing chunk.
---@param file string
---@return table
function include(file) return LoadModule(file) end

---Loads a module from the library.
---If the module has already been loaded then it will reference the existing chunk.
---@param file string
---@return table
function import(file) return LoadModule(file, LIBRARY) end

do
	local chunk, err = LoadResourceFile(RESOURCE, ('%s.lua'):format(SERVICE))
	local shared = LoadResourceFile(RESOURCE, ('shared.lua'))
	if shared then chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared end
	chunk, err = load(chunk, ('@@%s/%s.lua'):format(RESOURCE, SERVICE), 't')
	assert(chunk, ('^1%s^0'):format(err))
	chunk()
end

-- Library
-- Copyright (C) 2021	Linden <https://github.com/thelindat>

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.html>