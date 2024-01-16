local glm = require 'glm'

---@type table<number, CZone>
local Zones = {}
_ENV.Zones = Zones

local function removeZone(self)
    Zones[self.id] = nil
end

local glm_polygon_contains = glm.polygon.contains

local function contains(self, coords)
    return glm_polygon_contains(self.polygon, coords, self.thickness / 4)
end

local function insideSphere(self, coords)
    return #(self.coords - coords) < self.radius
end

local function convertToVector(coords)
    local _type = type(coords)

    if _type ~= 'vector3' then
        if _type == 'table' or _type == 'vector4' then
            return vec3(coords[1] or coords.x, coords[2] or coords.y, coords[3] or coords.z)
        end

        error(("expected type 'vector3' or 'table' (received %s)"):format(_type))
    end

    return coords
end

lib.zones = {
    ---@return CZone
    poly = function(data)
        data.id = #Zones + 1
        data.thickness = data.thickness or 4

        local pointN = #data.points
        local points = table.create(pointN, 0)

        for i = 1, pointN do
            points[i] = convertToVector(data.points[i])
        end

        data.polygon = glm.polygon.new(points)
        data.coords = data.polygon:centroid()
        data.type = 'poly'
        data.remove = removeZone
        data.contains = contains
        data.debug = nil
        data.debugColour = nil
        data.inside = nil
        data.onEnter = nil
        data.onExit = nil

        Zones[data.id] = data
        return data
    end,

    ---@return CZone
    box = function(data)
        data.id = #Zones + 1
        data.coords = convertToVector(data.coords)
        data.size = data.size and convertToVector(data.size) / 2 or vec3(2)
        data.thickness = data.size.z * 2 or 4
        data.rotation = quat(data.rotation or 0, vec3(0, 0, 1))
        data.polygon = (data.rotation * glm.polygon.new({
            vec3(data.size.x, data.size.y, 0),
            vec3(-data.size.x, data.size.y, 0),
            vec3(-data.size.x, -data.size.y, 0),
            vec3(data.size.x, -data.size.y, 0),
        }) + data.coords)
        data.type = 'box'
        data.remove = removeZone
        data.contains = contains
        data.debug = nil
        data.debugColour = nil
        data.inside = nil
        data.onEnter = nil
        data.onExit = nil

        Zones[data.id] = data
        return data
    end,

    ---@return CZone
    sphere = function(data)
        data.id = #Zones + 1
        data.coords = convertToVector(data.coords)
        data.radius = (data.radius or 2) + 0.0
        data.type = 'sphere'
        data.remove = removeZone
        data.contains = insideSphere
        data.debug = nil
        data.debugColour = nil
        data.inside = nil
        data.onEnter = nil
        data.onExit = nil

        Zones[data.id] = data
        return data
    end,

    getAllZones = function() return Zones end,
}

return lib.zones
