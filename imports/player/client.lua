--[[
	This module was experimental and won't be worked on or used further.
	May be removed in the future.
]]

local CPlayer = {}

function CPlayer:__index(index, ...)
    local method = CPlayer[index]

    if method then
        return function(...)
            return method(self, ...)
        end
    end
end

function CPlayer:getCoords(update)
    if update or not self.coords then
        self.coords = GetEntityCoords(cache.ped)
    end

    return self.coords
end

function CPlayer:getDistance(coords)
    return #(self:getCoords() - coords)
end

---@deprecated
function lib.getPlayer()
    return CPlayer
end

return lib.getPlayer
