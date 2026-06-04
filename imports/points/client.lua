--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

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

    lib.grid.removeEntry(self)

    points[self.id] = nil
end

local function hasRemovePoint(entry)
    return entry.remove == removePoint
end

CreateThread(function()
    while true do
        local coords = GetEntityCoords(cache.ped)
        local newPoints = lib.grid.getNearbyEntries(coords, hasRemovePoint) --[[@as CPoint[] ]]
        local cellX, cellY = lib.grid.getCellPosition(coords)
        cache.coords = coords
        closestPoint = nil

        if cellX ~= cache.lastCellX or cellY ~= cache.lastCellY then
            for i = 1, nearbyCount do
                local point = nearbyPoints[i]

                if point.inside then
                    local distance = #(coords - point.coords)

                    if distance > point.radius then
                        if point.onExit then point:onExit() end

                        point.inside = nil
                        point.currentDistance = nil
                    end
                end
            end

            cache.lastCellX = cellX
            cache.lastCellY = cellY
        end

        if nearbyCount ~= 0 then
            table.wipe(nearbyPoints)
            nearbyCount = 0
        end

        for i = 1, #newPoints do
            local point = newPoints[i]
            local distance = #(coords - point.coords)

            if distance <= point.radius then
                point.currentDistance = distance

                if not closestPoint or distance < (closestPoint.currentDistance or point.radius) then
                    if closestPoint then closestPoint.isClosest = nil end

                    point.isClosest = true
                    closestPoint = point
                end

                nearbyCount += 1
                nearbyPoints[nearbyCount] = point

                if not point.inside then
                    point.inside = true
                    if point.onEnter then
                        point:onEnter()
                    end
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
                    for i = nearbyCount, 1, -1 do
                        local point = nearbyPoints[i]

                        if point and point.nearby then
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

lib.points = {}

---@return CPoint
---@overload fun(data: PointProperties): CPoint
---@overload fun(coords: vector3, distance: number, data?: PointProperties): CPoint
function lib.points.new(...)
    local args = { ... }
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
    self.radius = self.distance

    if args[3] then
        for k, v in pairs(args[3]) do
            self[k] = v
        end
    end

    lib.grid.addEntry(self)
    points[id] = self

    return self
end

function lib.points.getAllPoints() return points end

function lib.points.getNearbyPoints() return nearbyPoints end

---@return CPoint?
function lib.points.getClosestPoint() return closestPoint end

---@deprecated
lib.points.closest = lib.points.getClosestPoint

return lib.points
