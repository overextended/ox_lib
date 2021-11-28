if not _VERSION:find('5.4') then
	error('^1Lua 5.4 must be enabled in the resource manifest!^0', 3)
end


-----------------------------------------------------------------------------------------------
-- Module
-----------------------------------------------------------------------------------------------

-- env
local LIBRARY = 'pe-lualib'
local SERVICE = IsDuplicityVersion() and 'server' or 'client'

-- micro-optimise
local rawget = rawget
local rawset = rawset
local LoadResourceFile = LoadResourceFile

local function loadFile(self, file)
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
			rawset(self, file, chunk())
			return setmetatable(self[file], {
				__index = {
					name = file,
					resource = LIBRARY
				},

				__newindex = function()
					error('Cannot add indexes to imports')
				end
			})
		end
	else error(('\n^3Unable to import module (%s)^0'):format(dir), 3) end
end

---Loads a module from the library.
---If the module has already been loaded then it will reference the existing chunk.
---@param file string
---@return table
local function getImport(self, file)
	local import = rawget(self, file)
	return import and import or loadFile(self, file)
end


-----------------------------------------------------------------------------------------------
-- Interface
-----------------------------------------------------------------------------------------------

import = setmetatable({}, {
	__index = getImport,

	__call = getImport,

	__newindex = function()
		error('Cannot add indexes to imports')
	end
})

local lib = {}
local msgpack_new = msgpack.new
local msgpack_unpack = msgpack.unpack
local getmetatable = getmetatable
local setmetatable = setmetatable

---@param tbl table
--- packs a table and metatable with msgpack
function lib.pack(tbl)
	local userdata = msgpack_new()
	userdata:_table(tbl)

	local mt = getmetatable(tbl)
	if mt then userdata:table(mt) end

	return tostring(userdata), not mt and true
end

---@param data string
--- unpacks a msgpack table and metatable
function lib.unpack(data)
	local tbl, mt = msgpack_unpack(data)
	return mt and setmetatable(tbl, mt) or tbl
end

setmetatable(lib, {
	__index = exports[LIBRARY],

	__tostring = function()
		return LIBRARY
	end,
})

_ENV.lib = lib

--- Dream of a world where this PR gets accepted.
--- ```lua
--- SetInterval(callback: function, timer: number)
--- ```
SetInterval = setmetatable({currentId = 0}, {
	__call = function(self, callback, timer)
		local id = self.currentId + 1
		self.currentId = id
		self[id] = timer or 0
		CreateThread(function()
			repeat
				local interval = self[id]
				Wait(interval)
				callback(interval)
			until interval == -1
			self[id] = nil
		end)
		return id
	end
})

function ClearInterval(id)
	if SetInterval[id] then
		SetInterval[id] = -1
	end
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