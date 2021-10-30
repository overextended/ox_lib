local SERVICE  = IsDuplicityVersion() and 'server' or 'client'
local RESOURCE = GetCurrentResourceName()

local MODULES = {}

local function LoadChunk(file)
    local chunk = LoadResourceFile(RESOURCE, ('imports/%s/%s.lua'):format(file, SERVICE))
    local shared = LoadResourceFile(RESOURCE, ('imports/%s/shared.lua'):format(file))
    if shared then
        chunk = chunk and ('%s\n%s'):format(shared, chunk) or shared
    end
    if chunk then
        return chunk and load(chunk, ('@%s.lua'):format(SERVICE), 't')
    end
    assert(nil, ('\n^Unable to load module (%s): module does not exist^0'):format(file))
end

function M(file)
    if not MODULES[file] then
        local chunk, err = LoadChunk(file)
        if err then
            assert(nil, ('\n^1Error loading module (%s): %s^0'):format(file, err))
        else
            MODULES[file] = chunk()
        end
    end
    return MODULES[file]
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