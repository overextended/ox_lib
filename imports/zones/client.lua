local glm = require 'glm'
local zones = {}

local function removeZone(self)
	zones[self.id] = nil
end

local function debug(self)
	local polygon = self.polygon
	local polyCount = #self.polygon

    for i = 1, polyCount do
        if i == polyCount then
            DrawPoly(polygon[i], polygon[1], self.centroid, 255, 0, 0, 50)
            DrawPoly(polygon[1], polygon[i], self.centroid, 255, 0, 0, 50)
        else
            DrawPoly(polygon[i], polygon[i + 1], self.centroid, 255, 0, 0, 50)
            DrawPoly(polygon[i + 1], polygon[i], self.centroid, 255, 0, 0, 50)
        end
    end
end

local inside = {}
local insideCount
local tick

CreateThread(function()
	while true do
		Wait(300)
		local coords = GetEntityCoords(cache.ped)
		table.wipe(inside)
		insideCount = 0

		for _, zone in pairs(zones) do
			local contains = zone.polygon:contains(coords, zone.thickness)

			if contains then
				if zone.inside then
					insideCount += 1
					inside[insideCount] = zone
				end

				if zone.onEnter and not zone.insideZone then
					zone.insideZone = true
					zone:onEnter()
				end
			elseif zone.insideZone then
				zone.insideZone = nil
				if zone.onExit then
					zone:onExit()
				end
			elseif zone.debug then
				insideCount += 1
				inside[insideCount] = zone
			end
		end

		if not tick then
			if insideCount > 0 then
				tick = SetInterval(function()
					for i = 1, insideCount do
						local zone = inside[i]

						if zone.insideZone then
							zone:inside()
						end

						if zone.debug then
							zone:debug()
						end
					end
				end)
			end
		elseif insideCount == 0 then
			tick = ClearInterval(tick)
		end
	end
end)

local glm_polygon_contains = glm.polygon.contains

local function contains(self, coords)
	return glm_polygon_contains(self.polygon, coords)
end

return {
	poly = function(data)
		data.id = #zones + 1
		data.thickness = data.thickness or 2
		data.polygon = glm.polygon.new(data.points)
		data.remove = removeZone
		data.centroid = data.polygon:centroid()
		data.debug = data.debug and debug
		data.contains = contains

		zones[data.id] = data
		return data
	end,

	box = function(data)
		data.id = #zones + 1
		data.thickness = data.size.z or 2
		data.polygon = glm.polygon.new({
			vec(data.size.x, data.size.y, 0),
			vec(-data.size.x, data.size.y, 0),
			vec(-data.size.x, -data.size.y, 0),
			vec(data.size.x, -data.size.y, 0),
		})
		data.rotation = quat(data.rotation or 0, vec(0, 0, 1))
		data.polygon = data.rotation * data.polygon
		data.polygon = data.polygon + data.centroid
		data.remove = removeZone
		data.debug = data.debug and debug
		data.contains = contains

		zones[data.id] = data
		return data
	end
}
