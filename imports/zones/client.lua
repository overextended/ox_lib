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
local tick

CreateThread(function()
	while true do
		local coords = GetEntityCoords(cache.ped)
		Wait(300)
		table.wipe(inside)

		for _, zone in pairs(zones) do
			local contains = zone.polygon:contains(coords, zone.thickness)

			if contains then
				if zone.inside then
					inside[#inside + 1] = zone
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
			end
		end

		if not tick then
			if #inside > 0 then
				tick = SetInterval(function()
					for i = 1, #inside do
						inside[i]:inside()
						if inside[i].debug then
							inside[i]:debug()
						end
					end
				end)
			end
		elseif #inside == 0 then
			tick = ClearInterval(tick)
		end
	end
end)

return {
	new = function(data)
		data.id = #zones + 1
		data.thickness = data.thickness or 2
		data.polygon = glm.polygon.new(data.points)
		data.remove = removeZone
		data.centroid = data.polygon:centroid()
		data.debug = data.debug and debug

		zones[data.id] = data
		return data
	end
}
