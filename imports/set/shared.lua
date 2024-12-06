---@class Set : OxClass
---@field private tracker table<any, boolean>
---@field private array any[]
lib.set = lib.class("Set")

---@param t? any[]
function lib.set:constructor(t)
  self.tracker = {}
  self.array = {}
  if type(t) == "table" and #t > 0 then
    for _, l in ipairs(t) do
      if not self.tracker[l] then
        self.tracker[l] = true
        self.array[#self.array + 1] = l
      end
    end
  end
  return self
end

---@param value any
function lib.set:add(value)
  if not self.tracker[value] then
    self.tracker[value] = true
    self.array[#self.array + 1] = value
  end
end

---@param value any
function lib.set:remove(value)
  if self.tracker[value] then
    self.tracker[value] = nil
    for i, v in ipairs(self.array) do
      if v == value then
        table.remove(self.array, i)
        break
      end
    end
  end
end

---@param value any
function lib.set:contains(value)
  return self.tracker[value]
end

---@param cb fun(v:any)
function lib.set:forEach(cb)
  for i=1, #self.array do
      cb(self.array[i])
  end
end

function lib.set:values()
  return self.array
end


return lib.set