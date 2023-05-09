---@class PointProperties
---@field coords vector3
---@field distance number
---@field onEnter? fun(self: CPoint)
---@field onExit? fun(self: CPoint)
---@field nearby? fun(self: CPoint)
---@field [string] any

---@class CPoint : PointProperties
---@field id number
---@field currentDistance number
---@field isClosest? boolean
---@field remove fun()

---@type table<number, CPoint>
local points = {}
---@type CPoint[]
local nearbyPoints = {}
local nearbyCount = 0
---@type CPoint?
local closestPoint
local tick

local function removePoint(self)
    if closestPoint?.id == self.id then
        closestPoint = nil
    end

	points[self.id] = nil
end

CreateThread(function()
	while true do
        if nearbyCount ~= 0 then
			table.wipe(nearbyPoints)
			nearbyCount = 0
		end

		local coords = GetEntityCoords(cache.ped)
		cache.coords = coords

        if closestPoint and #(coords - closestPoint.coords) > closestPoint.distance then
            closestPoint = nil
        end

		for _, point in pairs(points) do
			local distance = #(coords - point.coords)

			if distance <= point.distance then
				point.currentDistance = distance

                if closestPoint then
                    if distance < closestPoint.currentDistance then
                        closestPoint.isClosest = nil
                        point.isClosest = true
                        closestPoint = point
                    end
                elseif distance < point.distance then
                    point.isClosest = true
                    closestPoint = point
                end

				if point.nearby then
                    nearbyCount += 1
					nearbyPoints[nearbyCount] = point
				end

				if point.onEnter and not point.inside then
					point.inside = true
					point:onEnter()
				end
			elseif point.currentDistance then
				if point.onExit then point:onExit() end
				point.inside = nil
				point.currentDistance = nil
			end
		end

		if not tick then
			if nearbyCount ~= 0 then
				tick = SetInterval(function()
					for i = 1, nearbyCount do
                        local point = nearbyPoints[i]

                        if point then
                            point:nearby()
                        end
					end
				end)
			end
		elseif nearbyCount == 0 then
			tick = ClearInterval(tick)
		end

		Wait(300)
	end
end)

local function toVector(coords)
    local _type = type(coords)

    if _type ~= 'vector3' then
        if _type == 'table' or _type == 'vector4' then
            return vec3(coords[1] or coords.x, coords[2] or coords.y, coords[3] or coords.z)
        end

        error(("expected type 'vector3' or 'table' (received %s)"):format(_type))
    end

    return coords
end

lib.points = {
    ---@return CPoint
    ---@overload fun(data: PointProperties): CPoint
    ---@overload fun(coords: vector3, distance: number, data?: PointProperties): CPoint
	new = function(...)
		local args = {...}
		local id = #points + 1
		local self

		-- Support sending a single argument containing point data
		if type(args[1]) == 'table' then
			self = args[1]
			self.id = id
			self.remove = removePoint
		else
			-- Backwards compatibility for original implementation (args: coords, distance, data)
			self = {
				id = id,
				coords = args[1],
				remove = removePoint,
			}
		end

        self.coords = toVector(self.coords)
		self.distance = self.distance or args[2]

		if args[3] then
			for k, v in pairs(args[3]) do
				self[k] = v
			end
		end

		points[id] = self

		return self
	end,

    getAllPoints = function() return points end,

    getNearbyPoints = function() return nearbyPoints end,

    ---@return CPoint?
	getClosestPoint = function() return closestPoint end,
}

---@deprecated
lib.points.closest = lib.points.getClosestPoint

return lib.points
