--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class ObjectInitClient
---@field model string | number Model name or precomputed hash.
---@field coords vector3 Spawn coordinate.
---@field heading? number Applied via `SetEntityHeading` after spawn.
---@field rotation? vector3 Applied via `SetEntityRotation` after spawn (rotation order 2).
---@field isNetwork? boolean Whether to create a network object. Default `false`.
---@field netMissionEntity? boolean **GTA5 only.** Pin to script host. Default `false`.
---@field doorFlag? boolean **GTA5 only.** Set true to spawn door models in network mode.
---@field bScriptHostObj? boolean **RedM only.** Pin to script host. Default `false`.
---@field dynamic? boolean **RedM only.** Whether the object should be dynamic.
---@field p7? boolean **RedM only.** Undocumented. Default `false`.
---@field p8? boolean **RedM only.** Undocumented. Default `false`.

---Client-side spawnable object.
---@class ObjectClient : Entity
local ObjectClient = lib.class('ObjectClient', lib.entity)

---@param data ObjectInitClient
function ObjectClient:constructor(data)
    assert(type(data) == 'table', 'expected table init data')
    assert(data.coords and data.coords.x and data.coords.y and data.coords.z, 'expected vector3 coords')
    assert(type(data.model) == 'string' or type(data.model) == 'number', 'expected string or number model')

    local handle, modelHash = lib.entity.createClient(ObjectClient.spawn, data, 'ox_lib:createObject', 'object')

    self:super(handle)

    self.private.spawnData = data
    self.private.modelHash = modelHash

    if data.heading then self:setHeading(data.heading) end
    if data.rotation then self:setRotation(data.rotation) end
end

---@protected
---Internal spawn helper used by both the constructor and `:respawn()`.
---@param modelHash number
---@param data ObjectInitClient
---@return number handle
function ObjectClient.spawn(modelHash, data)
    if cache.game == 'redm' then
        return CreateObject(modelHash, data.coords.x, data.coords.y, data.coords.z,
            data.isNetwork or false, data.bScriptHostObj or false,
            data.dynamic or false, data.p7 or false, data.p8 or false)
    end

    return CreateObject(modelHash, data.coords.x, data.coords.y, data.coords.z,
        data.isNetwork or false, data.netMissionEntity or false, data.doorFlag or false)
end

lib.object = ObjectClient

return lib.object
