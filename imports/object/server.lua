--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class ObjectInitServer
---@field model string | number Model name or precomputed hash.
---@field coords vector3 Spawn coordinate.
---@field heading? number Applied via `SetEntityHeading` after spawn.
---@field rotation? vector3 Applied via `SetEntityRotation` after spawn (rotation order 2).
---@field orphanMode? EntityOrphanMode Server-side cleanup behavior. Default `2` (KeepEntity).
---@field doorFlag? boolean **GTA5 only.** Set true to spawn door models in network mode.
---@field dynamic? boolean **RedM only.** Whether the object should be dynamic (physics-driven).
---@field bScriptHostObj? boolean **RedM only.** Pin to script host. Defaults to `true`.
---@field p7? boolean **RedM only.** Undocumented. Default `false`.
---@field p8? boolean **RedM only.** Undocumented. Default `false`.

---Server-side spawnable object.
---@class ObjectServer : Entity
local ObjectServer = lib.class('ObjectServer', lib.entity)

---@param data ObjectInitServer
function ObjectServer:constructor(data)
    assert(type(data) == 'table', 'expected table init data')
    assert(data.coords and data.coords.x and data.coords.y and data.coords.z, 'expected vector3 coords')
    assert(type(data.model) == 'string' or type(data.model) == 'number', 'expected string or number model')

    local handle, modelHash = lib.entity.createServer(ObjectServer.spawn, data, 'object')

    self:super(handle)

    self.private.spawnData = data
    self.private.modelHash = modelHash

    if data.heading then self:setHeading(data.heading) end
    if data.rotation then self:setRotation(data.rotation) end

    if cache.game ~= 'redm' then
        self:setOrphanMode(data.orphanMode or 2)
    end
end

---@protected
---Internal spawn helper used by both the constructor and `:respawn()`.
---@param modelHash number
---@param data ObjectInitServer
---@return number handle
function ObjectServer.spawn(modelHash, data)
    if cache.game == 'redm' then
        return CreateObject(modelHash, data.coords.x, data.coords.y, data.coords.z,
            true, data.bScriptHostObj or false, data.dynamic or false, data.p7 or false, data.p8 or false)
    end

    return CreateObject(modelHash, data.coords.x, data.coords.y, data.coords.z, true, true, data.doorFlag or false)
end

lib.object = ObjectServer

-- Client→server proxy (gated by `ox:allowClientServerEntityCreation`).
lib.entity.registerCreateCallback(ObjectServer, 'ox_lib:createObject', 'object')

return lib.object
