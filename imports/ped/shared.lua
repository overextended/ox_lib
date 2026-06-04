--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class Ped : GameEntity
---@field private new PedConstructor
lib.ped = lib.class('Ped', lib.gameEntity)
lib.ped.type = lib.ped.__name

---@class PedConstructor
---@overload fun(self: Ped, handle: number): Ped
function lib.ped:constructor(handle)
    self:super()

    if handle > 0 then
        self:setHandle(handle)
    end
end

function lib.ped:__index(index)
    if index == 'handle' then
        return self.private.handle
    end

    return lib.ped[index]
end

function lib.ped:getArmour()
    return GetPedArmour(self.handle)
end

---@param amount number
function lib.ped:setArmour(amount)
    SetPedArmour(self.handle, amount)
end

