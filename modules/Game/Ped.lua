--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@meta Ox.Game.Ped

local GameEntity = require 'Ox.Game.Entity'
local isServer = lib.context == 'server'

---@class Ped : GameEntity
---@field new PedConstructor
local Ped = Class('Ped', GameEntity)
Ped.type = Ped.__name

---@param model string | number
---@param x number
---@param y number
---@param z number
---@param heading? number
---@param isNetworked? boolean client defaults to false; does nothing on the server.
---@param bScriptHostPed? boolean client defaults to false; does nothing on the server.
---@return Ped
---@see CreatePed
function Ped.create(model, x, y, z, heading, isNetworked, bScriptHostPed)
    isNetworked = isServer or isNetworked or false
    bScriptHostPed = isServer or bScriptHostPed or false
    local hash = isServer and model or lib.requestModel(model)
    local handle = CreatePed(0, hash, x, y, z, heading or 0, isNetworked, bScriptHostPed)

    if not isServer then SetModelAsNoLongerNeeded(hash) end

    return Ped:new(handle)
end

---@class PedConstructor
---@overload fun(self: Ped, handle: number): Ped
function Ped:constructor(handle)
    self:super()

    if handle > 0 then
        self:setHandle(handle)
    end
end

function Ped:__index(index)
    if index == 'handle' then
        return self.private.handle
    end

    return Ped[index]
end

function Ped:getArmour()
    return GetPedArmour(self.handle)
end

---@param amount number
function Ped:setArmour(amount)
    SetPedArmour(self.handle, amount)
end

return Ped
