local glm = require 'glm'
local zones = {}

local function removeZone(self)
	zones[self.id] = nil
end

local nearby = {}
local tick

CreateThread(function()
	while true do
		local coords = GetEntityCoords(cache.ped)
		Wait(300)
		table.wipe(nearby)

		for _, zone in pairs(zones) do
			local distance = #(coords - zone.polygon:centroid())

			if distance <= zone.inRange then
				if zone.nearby then
					nearby[#nearby + 1] = zone
				end

				if zone.polygon:contains(coords, zone.thickness) then
					if zone.onEnter and not zone.inside then
						zone.inside = true
						zone:onEnter()
					end
				elseif zone.inside then
					if zone.onExit then zone:onExit() end
					zone.inside = nil
				end
			end
		end

		if not tick then
			if #nearby > 0 then
				tick = SetInterval(function()
					for i = 1, #nearby do
						nearby[i]:nearby()
						if nearby[i].debug then
							nearby[i]:drawPolygon()
						end
					end
				end)
			end
		elseif #nearby == 0 then
			tick = ClearInterval(tick)
		end
	end
end)

return {
	new = function(points, thickness, data)
		local id = #zones + 1
		local self = {
			id = id,
			thickness = thickness,
			polygon = glm.polygon.new(points),
			remove = removeZone
		}

		if data then
			for k, v in pairs(data) do
				self[k] = v
			end
		end

		if self.debug and not self.nearby then
			self.nearby = function() end
		end

		local centroid = self.polygon:centroid()
		local length = #self.polygon

		self.maxDistance = 0
		for i = 1, length do
			local difference = #(centroid - points[i])
			if difference > self.maxDistance then
				self.maxDistance = difference
			end
		end

		self.inRange = self.inRange or self.maxDistance * 1.5

		self.drawPolygon = function()
			local points = self.polygon()
			for i = 1, #points do
				if i == #points then
					DrawPoly(points[i], points[1], centroid, 255, 0, 0, 50)
					DrawPoly(points[1], points[i], centroid, 255, 0, 0, 50)
				else
					DrawPoly(points[i], points[i + 1], centroid, 255, 0, 0, 50)
					DrawPoly(points[i + 1], points[i], centroid, 255, 0, 0, 50)
				end
			end
		end

		zones[id] = self
		return self
	end
}
