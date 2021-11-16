if not _VERSION:find('5.4') then
	error('^1Lua 5.4 must be enabled in the resource manifest!^0', 3)
end

local LIBRARY  = 'pe-lualib'
local SERVICE  = IsDuplicityVersion() and 'server' or 'client'
local IMPORTS  = {}

lib = exports[LIBRARY]

local function LoadFile(file)
	local dir = ('imports/%s'):format(file)
	local chunk = LoadResourceFile(LIBRARY, ('%s/%s.lua'):format(dir, SERVICE))
	local shared = LoadResourceFile(LIBRARY, ('%s/shared.lua'):format(dir))
	if shared then
		chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
	end
	if chunk then
		local err
		chunk, err = load(chunk, ('@@%s.lua'):format(SERVICE), 't')
		if err then
			error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
		else
			IMPORTS[file] = chunk()
		end
	else error(('\n^3Unable to import module (%s)^0'):format(dir), 3) end
end

---Loads a module from the library.
---If the module has already been loaded then it will reference the existing chunk.
---@param file string
---@return table
function import(file)
	if not IMPORTS[file] then LoadFile(file) end
	return IMPORTS[file]
end

-- pe-lualib
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