---@class CPoint
---@field id number
---@field coords vector3
---@field nearbyDistance number
---@field distance number
---@field currentDistance number
---@field remove fun()
---@field onEnter fun(self: CPoint)?
---@field onExit fun(self: CPoint)?
---@field nearby fun(self: CPoint)?

local points = {}

local function removePoint(self)
	points[self.id] = nil
end

local nearbyPoints = {}
local nearbyCount = 0
local closestPoint
local tick

CreateThread(function()
	while true do
        if nearbyCount ~= 0 then
			table.wipe(nearbyPoints)
			nearbyCount = 0
		end

		local coords = GetEntityCoords(cache.ped)
		cache.coords = coords
        closestPoint = nil

		for _, point in pairs(points) do
			local distance = #(coords - point.coords)

			if distance <= point.nearbyDistance then
				if point.nearby then
                    nearbyCount += 1
					nearbyPoints[nearbyCount] = point
				end
			end

			if distance <= point.distance then
				point.currentDistance = distance

                ---@diagnostic disable-next-line: need-check-nil
				if distance < (closestPoint?.currentDistance or point.distance) then
					closestPoint = point
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
						nearbyPoints[i]:nearby()
					end
				end)
			end
		elseif nearbyCount == 0 then
			tick = ClearInterval(tick)
		end

		Wait(300)
	end
end)

lib.points = {
    ---@return CPoint
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

		self.distance = self.distance or args[2]
		self.nearbyDistance = self.nearbyDistance or self.distance or args[2]

		if args[3] then
			for k, v in pairs(args[3]) do
				self[k] = v
			end
		end

		points[id] = self

		return self
	end,

    ---@return CPoint
	closest = function()
		return closestPoint
	end
}

return lib.points
