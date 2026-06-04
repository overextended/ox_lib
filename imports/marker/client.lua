--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@diagnostic disable: param-type-mismatch
lib.marker = {}

---@enum (key) MarkerType
local markerTypes = {
  UpsideDownCone = 0,
  VerticalCylinder = 1,
  ThickChevronUp = 2,
  ThinChevronUp = 3,
  CheckeredFlagRect = 4,
  CheckeredFlagCircle = 5,
  VerticleCircle = 6,
  PlaneModel = 7,
  LostMCTransparent = 8,
  LostMC = 9,
  Number0 = 10,
  Number1 = 11,
  Number2 = 12,
  Number3 = 13,
  Number4 = 14,
  Number5 = 15,
  Number6 = 16,
  Number7 = 17,
  Number8 = 18,
  Number9 = 19,
  ChevronUpx1 = 20,
  ChevronUpx2 = 21,
  ChevronUpx3 = 22,
  HorizontalCircleFat = 23,
  ReplayIcon = 24,
  HorizontalCircleSkinny = 25,
  HorizontalCircleSkinny_Arrow = 26,
  HorizontalSplitArrowCircle = 27,
  DebugSphere = 28,
  DollarSign = 29,
  HorizontalBars = 30,
  WolfHead = 31,
  QuestionMark = 32,
  PlaneSymbol = 33,
  HelicopterSymbol = 34,
  BoatSymbol = 35,
  CarSymbol = 36,
  MotorcycleSymbol = 37,
  BikeSymbol = 38,
  TruckSymbol = 39,
  ParachuteSymbol = 40,
  Unknown41 = 41,
  SawbladeSymbol = 42,
  Unknown43 = 43,
}

---@class MarkerProps
---@field type? MarkerType | integer
---@field coords { x: number, y: number, z: number }
---@field width? number
---@field height? number
---@field color? { r: integer, g: integer, b: integer, a: integer }
---@field rotation? { x: number, y: number, z: number }
---@field direction? { x: number, y: number, z: number }
---@field bobUpAndDown? boolean
---@field faceCamera? boolean
---@field rotate? boolean
---@field textureDict? string
---@field textureName? string
---@field invert? boolean

local vector3_zero = vector3(0, 0, 0)

local marker_mt = {
  type = 0,
  width = 2.,
  height = 1.,
  color = {r = 255, g = 100, b = 0, a = 100},
  rotation = vector3_zero,
  direction = vector3_zero,
  bobUpAndDown = false,
  faceCamera = false,
  rotate = false,
  invert = false,
}
marker_mt.__index = marker_mt

function marker_mt:draw()
  DrawMarker(
    self.type,
    self.coords.x, self.coords.y, self.coords.z,
    self.direction.x, self.direction.y, self.direction.z,
    self.rotation.x, self.rotation.y, self.rotation.z,
    self.width, self.width, self.height,
    self.color.r, self.color.g, self.color.b, self.color.a,
    self.bobUpAndDown, self.faceCamera, 2, self.rotate, self.textureDict, self.textureName, self.invert)
end

---@param options MarkerProps
function lib.marker.new(options)
  options.type =
    type(options.type) == 'string' and markerTypes[options.type]
    or type(options.type) == 'number' and options.type or nil

  local self = setmetatable(options, marker_mt)

  self.width += .0
  self.height += .0

  return self
end

return lib.marker
