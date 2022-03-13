local points = {}
local nearby = {}

function points.new(coords, distance, data)
	local id = #points + 1

	local self = {
		id = id,
		coords = coords,
		distance = distance
	}

	for k, v in pairs(data) do
		self[k] = v
	end

	points[id] = self

	return self
end

CreateThread(function()
	while true do
		local coords = GetEntityCoords(cache.ped)
		Wait(300)
		table.wipe(nearby)

		for i = 1, #points do
			local point = points[i]
			local distance = #(coords - point.coords)

			if distance <= point.distance then
				nearby[#nearby + 1] = point
				point.currentDistance = distance
			elseif point.currentDistance then
				if point.onExit then point:onExit() end
				point.entered = nil
				point.currentDistance = nil
			end
		end
	end
end)

CreateThread(function()
	while true do
		Wait(0)
		for i = 1, #nearby do
			local point = nearby[i]
			if point.callback then point:callback() end
		end
	end
end)

return points