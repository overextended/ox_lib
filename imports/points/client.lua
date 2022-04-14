local points = {}

local function removePoint(self)
	points[self.id] = nil
end

local nearby = {}
local closest

CreateThread(function()
	while true do
		local coords = GetEntityCoords(cache.ped)
		Wait(300)
		closest = nil
		table.wipe(nearby)

		for _, point in pairs(points) do
			local distance = #(coords - point.coords)

			if distance <= point.distance then
				point.currentDistance = distance

				if distance < (closest?.currentDistance or point.distance) then
					closest = point
				end

				if point.nearby then
					nearby[#nearby + 1] = point
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
	end
end)

CreateThread(function()
	while true do
		Wait(0)
		for i = 1, #nearby do
			nearby[i]:nearby()
		end
	end
end)

return {
	new = function(coords, distance, data)
		local id = #points + 1

		local self = {
			id = id,
			coords = coords,
			distance = distance,
			remove = removePoint,
		}

		if data then
			for k, v in pairs(data) do
				self[k] = v
			end
		end

		points[id] = self

		return self
	end,

	closest = function()
		return closest
	end
}
