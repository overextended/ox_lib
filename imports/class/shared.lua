lib.print.warn('ox_lib\'s class module is experimental and may break without warning.')

-- Fields added to the "private" field on a class will not be msgpacked.
-- Use setters/getters when working with these values.
local private_mt = {
    __ext = 0,
    __pack = function() return '' end,
}

---Ensure the given argument or property has a valid type, otherwise throwing an error.
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

---Creates a new instance of the given class.
local function createObj(class, obj)
    if obj.private then
        assertType('private', obj.private, 'table')
        setmetatable(obj.private, private_mt)
    end

    setmetatable(obj, class)

    if class.init then obj:init() end

    return obj
end

---Creates a new class.
---@param name string
---@param super? table
function lib.class(name, super)
    assertType(1, name, 'string')

    local class = {
        __name = name,
        new = createObj,
    }

    class.__index = class

    return super and setmetatable(class, super) or class
end

return lib.class

--[[
---@type table<string, Fruit>
local fruits = {}

---@class Fruit
---@field private new fun(self: self, obj): self
---@field private init fun(self: self)
---@field private private table
---@field name string
---@field colour string
local Fruit = lib.class('Fruit')

function Fruit:__gc() print('ran __gc', self.name) end

function Fruit:__close()
    print('closed', self.name); self:remove()
end

function Fruit:init()
    print(('Created a %s %s'):format(self:getColour(), self:getName()))
    fruits[self.name] = self
end

function Fruit:remove()
    print('Removed', self:getName(), self)
    fruits[self.name] = nil
end

function Fruit:getName() return self.name end

function Fruit:getColour() return self.colour end

function Fruit:getSeeds() return self.private.seeds end

---@class SpoiledFruit : Fruit
---@field private new fun(self: self, obj): self
---@field stench string
local SpoiledFruit = lib.class('SpoiledFruit', Fruit)

function SpoiledFruit:getStench() return self.stench end

CreateThread(function()
    local apple = Fruit:new({
        name = 'apple',
        colour = math.random(0, 1) == 1 and 'red' or 'green'
    })

    local orange <close> = Fruit:new({
        name = 'orange',
        colour = 'orange',
        private = {
            seeds = 7
        }
    })

    print(('the apple is %s'):format(apple:getColour()))
    print(('the orange contains %d seeds'):format(orange:getSeeds()))
    --print(orange.private.seeds)

    apple:remove()

    local rottenBanana = SpoiledFruit:new({
        name = 'banana',
        colour = 'black',
        stench = 'musty'
    })

    print(('the banana is %s and %s - gross!'):format(rottenBanana:getColour(), rottenBanana:getStench()))
end)
]]
