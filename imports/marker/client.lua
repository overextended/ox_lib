lib.marker = {}

local defaultRotation = { x = 0, y = 0, z = z }
local defaultDirection = { x = 0, y = 0, z = z }
local defaultColor = { r = 255, g = 255, b = 255, a = 100 }
local defaultSize = { width = 2, height = 1 }

---@enum MarkerType
MarkerTypes = {
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
---@field type MarkerType | integer
---@field coords { x: number, y: number, z: number }
---@field size? { width: number, height: number }
---@field color? { r: number, g: number, b: number, a: number }
---@field rotation? { x: number, y: number, z: number }
---@field direction? { x: number, y: number, z: number }

---@param self MarkerProps
local function drawMarker(self)
  DrawMarker(
    self.type,
    self.coords.x, self.coords.y, self.coords.z,
    self.direction.x, self.direction.y, self.direction.z,
    self.rotation.x, self.rotation.y, self.rotation.z,
    self.size.width, self.size.width, self.size.height,
    self.color.r, self.color.g, self.color.b, self.color.a,
    ---@diagnostic disable-next-line: param-type-mismatch
    false, true, 2, false, nil, nil, false)
end

---@param options MarkerProps
function lib.marker.new(options)
  local markerType = type(options.type)
  if markerType ~= "number" and markerType ~= "string" then
    error(("expected marker type to have type 'number' or 'string' (received %s)"):format(markerType))
  end

  local self = {}
  self.type = options.type
  self.coords = options.coords
  self.color = options.color or defaultColor
  self.size = options.size or defaultSize
  self.rotation = options.rotation or defaultRotation
  self.direction = options.direction or defaultDirection
  self.draw = drawMarker

  self.size.width += 0.0
  self.size.height += 0.0

  return self
end

return lib.marker
