lib.print.warn('ox_lib\'s class module is experimental and may break without warning.')

lib.class = {}

-- Fields added to the "private" field on a class will not be msgpacked.
-- Use setters/getters when working with these values.
local private_mt = {
    __ext = 0,
    __pack = function() return '' end,
}

---@param id number | string
---@param var any
---@param expected type
local function assertType(id, var, expected)
    local received = type(var)

    if received ~= expected then
        error(("expected %s %s to have type '%s' (received %s)"):format(type(id) == 'string' and 'field' or 'argument', id, expected, received), 3)
    end

    return true
end

local function newClass(self, obj)
    if obj.private then
        assertType('private', obj.private, 'table')
        setmetatable(obj.private, private_mt)
    end

    setmetatable(obj, self)

    if self.init then obj:init() end

    return obj
end

---@param self table
---@param metamethod string
---@param value any
local function setMetamethod(self, metamethod, value)
    local mt = getmetatable(self)

    if not mt then return error('no metatable') end
    if not metamethod:match('^__%w+$') then return error('invalid metamethod') end

    rawset(getmetatable(self), metamethod, value)
end

---@param name string
function lib.class.new(name)
    assertType(1, name, 'string')

    local data = {}
    local class = {
        __index = data,
        __newindex = data,
        __name = name or nil,
        new = newClass,
        setMetamethod = setMetamethod,
    }

    return setmetatable(class, class)
end

return lib.class

--[[
---@type table<string, Fruit>
local fruits = {}

---@class Fruit
---@field private new fun(self: self, obj): self
---@field private setMetamethod fun(self: self, metamethod: string, value: any)
---@field private init fun(self: self)
---@field private private table
---@field name string
---@field colour string
local Fruit = lib.class.new('Fruit')

function Fruit:init()
    print(('Created an %s %s'):format(self:getColour(), self:getName()))
    fruits[self.name] = self
end

function Fruit:remove()
    print('Removed', self:getName(), self)
    fruits[self.name] = nil
end

Fruit:setMetamethod('__gc', function(self) print('ran __gc', self.name) end)

function Fruit:getName() return self.name end
function Fruit:getColour() return self.colour end
function Fruit:getSeeds() return self.private.seeds end

CreateThread(function()
    local apple = Fruit:new({
        name = 'apple',
        colour = 'red'
    })

    local orange = Fruit:new({
        name = 'orange',
        colour = 'orange',
        private = {
            seeds = 7
        }
    })

    if apple:getColour() == 'red' then
        print('the apple is red')
    end

    print(('the orange contains %d seeds'):format(orange:getSeeds()))

    for _, fruit in pairs(fruits) do
        fruit:remove()
    end
end)
]]
