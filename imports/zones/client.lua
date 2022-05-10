local glm = require 'glm'
Zones = {}

local function getTriangles(polygon)
	local extremes = { polygon.projectToAxis(polygon, vec(1, 0, 0)) }

	local points = {}
	local sides = {}
	local horizontals = {}
	local triangles = {}

	local h
	for i = 1, #polygon do
		local point = polygon[i]
		local unique = true

		for j = 1, #horizontals do
			if point.y == horizontals[j][1].y then
				h = j
				horizontals[j][#horizontals[j] + 1] = point
				unique = false
				break
			end
		end

		if unique then
			h = #horizontals + 1
			horizontals[h] = {point}
		end

		sides[i] = {polygon[i], polygon[i + 1] or polygon[1]}
		points[polygon[i]] = {side = i, horizontal = h, uses = 0}
	end

	for i = 1, #horizontals do
		local horizontal = horizontals[i]
		local hLineStart, hLineEnd = vec(extremes[1], horizontal[1].yz), vec(extremes[2], horizontal[1].yz)
		for j = 1, #sides do
			local sideStart, sideEnd = sides[j][1], sides[j][2]
			local bool, d, d2 = glm.segment.intersectsSegment(hLineStart, hLineEnd, sideStart, sideEnd)
			if d > 0.001 and d < 0.999 and d2 > 0.001 and d2 < 0.999 then
				local newPoint = glm.segment.getPoint(hLineStart, hLineEnd, d)
				local valid
				for l = 1, #horizontal do
					local point = horizontal[l]
					valid = polygon.contains(polygon, (point + newPoint) / 2, 0.1)
					if valid then
						for m = 1, #sides do
							local sideStart, sideEnd = sides[m][1], sides[m][2]
							local bool, d, d2 = glm.segment.intersectsSegment(point, newPoint, sides[m][1], sides[m][2])
							if d > 0.001 and d < 0.999 and d2 > 0.001 and d2 < 0.999 then
								valid = false
								break
							end
						end
					end
					if valid then
						horizontals[i][#horizontals[i] + 1] = newPoint
						sides[j][#sides[j] + 1] = newPoint
						points[newPoint] = {side = j, horizontal = i, uses = 0}
						break
					end
				end
			end
		end
	end

	local function up(a, b)
		return a.y > b.y
	end

	local function down(a, b)
		return a.y < b.y
	end

	local function right(a, b)
		return a.x > b.x
	end

	local function left(a, b)
		return a.x < b.x
	end

	local function makeTriangles(t)
		if t[3] and t[4] then
			triangles[#triangles + 1] = mat(t[1], t[2], t[3])
			triangles[#triangles + 1] = mat(t[2], t[3], t[4])
			for i = 1, #t do
				points[t[i]].uses += 1
			end
		else
			triangles[#triangles + 1] = mat(t[1], t[2], t[3] or t[4])
			for k, v in pairs(t) do
				points[v].uses += 2
			end
		end
	end

	for i = 1, #sides do
		local side = sides[i]

		local direction = side[1].y - side[2].y
		direction = direction > 0 and up or down
		table.sort(side, direction)

		for j = 1, #side - 1 do
			local a, b = side[j], side[j + 1]
			local aData, bData = points[a], points[b]
			local aPos, bPos
			if aData.horizontal ~= bData.horizontal then
				local aHorizontal, bHorizontal = horizontals[aData.horizontal], horizontals[bData.horizontal]
				local c, d

				if aHorizontal[2] then
					local direction = a.x - (a.x ~= aHorizontal[1].x and aHorizontal[1].x or aHorizontal[2].x)
					direction = direction > 0 and right or left
					table.sort(aHorizontal, direction)

					for l = 1, #aHorizontal do
						if a == aHorizontal[l] then
							aPos = l
						elseif c and aPos then
							break
						else
							c = aHorizontal[l]
						end
					end
				end

				if bHorizontal[2] then
					local direction = b.x - (b.x ~= bHorizontal[1].x and bHorizontal[1].x or bHorizontal[2].x)
					direction = direction > 0 and right or left
					table.sort(bHorizontal, direction)

					for l = 1, #bHorizontal do
						if b == bHorizontal[l] then
							bPos = l
						elseif bPos and d then
							break
						else
							d = bHorizontal[l]
						end
					end
				end

				if aData.uses < 2 then
					if c and d then
						if points[c].side ~= points[d].side then
							local done
							for l = aPos > 1 and aPos - 1 or 1, aPos > #aHorizontal and aPos + 1 or #aHorizontal do
								c = aHorizontal[l]
								if c ~= a then
									for m = bPos > 1 and bPos - 1 or 1, bPos > #bHorizontal and bPos + 1 or #bHorizontal do
										d = bHorizontal[m]
										local sideDifference = points[c].side - points[d].side
										if d ~= b and sideDifference >= -1 and sideDifference <= 1 then
											done = true
											break
										end
									end
								end
								if done then break end
							end
						end
						c = polygon.contains(polygon, (a + c) / 2, 0.1) and c or nil
						d = polygon.contains(polygon, (b + d) / 2, 0.1) and d or nil
					end

					if c and not d then
						for l = aPos > 1 and aPos - 1 or 1, aPos < #aHorizontal and aPos + 1 or #aHorizontal do
							c = aHorizontal[l]
							if c and c ~= a then
								local sideDifference = bData.side - points[c].side
								if sideDifference >= -1 and sideDifference <= 1 then
									break
								end
							end
						end
					elseif d and not c then
						for l = bPos > 1 and bPos - 1 or 1, bPos < #bHorizontal and bPos + 1 or #bHorizontal do
							d = aHorizontal[l]
							if d and d ~= b then
								local sideDifference = aData.side - points[d].side
								if sideDifference >= -1 and sideDifference <= 1 then
									break
								end
							end
						end
					end

					if c or d then
						makeTriangles({a, b, c, d})
					end
				end
			else
				aData.uses += 1
				bData.uses += 1
			end
		end
	end
	return triangles
end

local function removeZone(self)
	Zones[self.id] = nil
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

		for _, zone in pairs(Zones) do
			local contains = zone:contains(coords)

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

local function debugPoly(self)
	if self.triangles then
		for i = 1, #self.triangles do
			local triangle = self.triangles[i]
			DrawPoly(triangle[1], triangle[2], triangle[3], 255, 42, 24, 100)
			DrawPoly(triangle[2], triangle[1], triangle[3], 255, 42, 24, 100)
		end
	else
		local polygon = self.polygon

		for i = 2, #self.polygon - 1 do
			DrawPoly(polygon[1], polygon[i], polygon[i + 1], 255, 42, 24, 100)
			DrawPoly(polygon[i], polygon[1], polygon[i + 1], 255, 42, 24, 100)
		end
	end
end

local DrawLine = DrawLine

local function debugBox(self)
	DrawLine(self.vertices[1], self.vertices[2], 255, 42, 24, 225)
	DrawLine(self.vertices[2], self.vertices[3], 255, 42, 24, 225)
	DrawLine(self.vertices[3], self.vertices[4], 255, 42, 24, 225)
	DrawLine(self.vertices[4], self.vertices[1], 255, 42, 24, 225)

	DrawLine(self.vertices[5], self.vertices[6], 255, 42, 24, 225)
	DrawLine(self.vertices[6], self.vertices[7], 255, 42, 24, 225)
	DrawLine(self.vertices[7], self.vertices[8], 255, 42, 24, 225)
	DrawLine(self.vertices[8], self.vertices[5], 255, 42, 24, 225)

	DrawLine(self.vertices[1], self.vertices[7], 255, 42, 24, 225)
	DrawLine(self.vertices[2], self.vertices[8], 255, 42, 24, 225)
	DrawLine(self.vertices[3], self.vertices[5], 255, 42, 24, 225)
	DrawLine(self.vertices[4], self.vertices[6], 255, 42, 24, 225)
end

local function debugSphere(self)
	DrawMarker(28, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, self.radius, self.radius, self.radius, 255, 42, 24, 100, false, false, false, true, false, false, false)
end

local glm_polygon_contains = glm.polygon.contains

local function contains(self, coords)
	return glm_polygon_contains(self.polygon, coords, self.thickness)
end

local function insideSphere(self, coords)
	return #(self.coords - coords) < self.radius
end

local function getBoxVertices(self)
	return {
		self.coords + vec3(self.size.x, self.size.y, self.thickness) * self.rotation,
		self.coords + vec3(-self.size.x, self.size.y, self.thickness) * self.rotation,
		self.coords + vec3(-self.size.x, -self.size.y, self.thickness) * self.rotation,
		self.coords + vec3(self.size.x, -self.size.y, self.thickness) * self.rotation,
		self.coords - vec3(self.size.x, self.size.y, self.thickness) * self.rotation,
		self.coords - vec3(-self.size.x, self.size.y, self.thickness) * self.rotation,
		self.coords - vec3(-self.size.x, -self.size.y, self.thickness) * self.rotation,
		self.coords - vec3(self.size.x, -self.size.y, self.thickness) * self.rotation,
	}
end

return {
	poly = function(data)
		data.id = #Zones + 1
		data.thickness = data.thickness or 2
		data.polygon = glm.polygon.new(data.points)
		data.coords = data.polygon:centroid()
		data.remove = removeZone
		data.contains = contains

		if data.debug then
			data.triangles = not data.polygon:isConvex() and getTriangles(data.polygon)
			data.debug = debugPoly
		end

		Zones[data.id] = data
		return data
	end,

	box = function(data)
		data.id = #Zones + 1
		data.thickness = data.size.z or 2
		data.rotation = quat(data.rotation or 0, vec3(0, 0, 1))
		data.polygon = (data.rotation * glm.polygon.new({
			vec3(data.size.x, data.size.y, 0),
			vec3(-data.size.x, data.size.y, 0),
			vec3(-data.size.x, -data.size.y, 0),
			vec3(data.size.x, -data.size.y, 0),
		}) + data.coords)
		data.remove = removeZone
		data.contains = contains

		if data.debug then
			data.vertices = getBoxVertices(data)
			data.debug = debugBox
		end

		Zones[data.id] = data
		return data
	end,

	sphere = function(data)
		data.id = #Zones + 1
		data.radius = (data.radius or 2) + 0.0
		data.remove = removeZone
		data.contains = insideSphere

		if data.debug then
			data.debug = debugSphere
		end

		Zones[data.id] = data
		return data
	end,
}
