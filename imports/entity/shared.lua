--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

-- Capture the global `Entity()` state-bag accessor before our local class shadows it.
local getEntityStateBag = Entity

---Base class wrapping a CFX entity handle. Used directly via `lib.entity:new(handle)`
---to wrap any pre-existing entity, or as the parent of `lib.object`, `lib.ped`, and
---`lib.vehicle` for typed spawn wrappers.
---@class Entity : OxClass
---@field handle number Native entity handle.
---@field script string Resource that created or wrapped this entity.
local Entity = lib.class('Entity')

local IS_SERVER = IsDuplicityVersion()

---@param handle number
function Entity:constructor(handle)
    local handleType = type(handle)
    assert(handleType == 'number' and handle ~= 0, ('expected non-zero entity handle, got %s (%s)'):format(handleType, tostring(handle)))

    self.handle = handle
    self.script = GetInvokingResource() or cache.resource
end

function Entity:exists()
    return DoesEntityExist(self.handle)
end

function Entity:delete()
    if self:exists() then
        DeleteEntity(self.handle)
    end
end

---@return vector3
function Entity:getCoords()
    return GetEntityCoords(self.handle)
end

---@param coords vector3
---@param alive? boolean Unused by the game; debug-only assert flag. Default `false`.
---@param deadFlag? boolean Disable physics for dead peds as well. Default `false`.
---@param ragdollFlag? boolean Special flag used for ragdolling peds. Default `false`.
---@param clearArea? boolean Clear any entities in the target area. Default `false`.
function Entity:setCoords(coords, alive, deadFlag, ragdollFlag, clearArea)
    SetEntityCoords(self.handle, coords.x, coords.y, coords.z, alive or false, deadFlag or false, ragdollFlag or false, clearArea or false)
end

---@return number
function Entity:getHeading()
    return GetEntityHeading(self.handle)
end

---@param heading number
function Entity:setHeading(heading)
    SetEntityHeading(self.handle, heading + 0.0)
end

---@return vector3
function Entity:getRotation()
    return GetEntityRotation(self.handle, 2)
end

---@param rotation vector3
function Entity:setRotation(rotation)
    SetEntityRotation(self.handle, rotation.x + 0.0, rotation.y + 0.0, rotation.z + 0.0, 2, true)
end

---@return number
function Entity:getModel()
    return GetEntityModel(self.handle)
end

---Returns the entity's state bag.
function Entity:getState()
    return getEntityStateBag(self.handle).state
end

---Re-spawn the entity at new coords, preserving the original constructor data.
---Subclasses must provide a static `spawn(modelHash, data)` returning a new handle.
---@param coords? vector3 Defaults to the entity's current coords (or the original spawn coords).
---@param heading? number Defaults to the entity's current heading.
---@return number? handle New entity handle, or nil on failure.
function Entity:respawn(coords, heading)
    local cls = getmetatable(self)
    if type(cls.spawn) ~= 'function' then
        error(('%s:respawn is not implemented (missing static `spawn`)'):format(cls.__name or 'Entity'), 2)
    end

    local priv = self.private or {}
    local exists = self:exists()
    local modelHash = priv.modelHash or (exists and GetEntityModel(self.handle)) or nil
    local fallbackCoords = exists and self:getCoords() or nil
    local fallbackHeading = exists and self:getHeading() or nil

    coords = coords or fallbackCoords or (priv.spawnData and priv.spawnData.coords)
    if not coords then return nil end
    heading = heading or fallbackHeading or (priv.spawnData and priv.spawnData.heading)

    if not modelHash then return nil end

    if exists then DeleteEntity(self.handle) end

    local data = priv.spawnData and table.clone(priv.spawnData) or {}
    data.coords = coords
    data.heading = heading

    local newHandle = cls.spawn(modelHash, data)
    if newHandle == 0 then return nil end

    self.handle = newHandle

    if heading then self:setHeading(heading) end
    if data.rotation then self:setRotation(data.rotation) end

    if IS_SERVER and cache.game ~= 'redm' then
        self:setOrphanMode(data.orphanMode or 2)
    end

    -- Cache the latest spawn data in case it was mutated.
    if self.private then self.private.spawnData = data end

    self:onAfterRespawn(data)

    return newHandle
end

---@protected
---@param data table The cloned spawn data used for this respawn.
function Entity:onAfterRespawn(data) end

if IS_SERVER then
    local allowClientServerEntityCreation = GetConvarInt('ox:allowClientServerEntityCreation', 0) == 1

    ---@return number networkId
    function Entity:getNetworkId()
        return NetworkGetNetworkIdFromEntity(self.handle)
    end

    ---@param mode EntityOrphanMode
    function Entity:setOrphanMode(mode)
        if cache.game == 'redm' then
            lib.print.warn('Entity:setOrphanMode is unavailable on RedM (no SetEntityOrphanMode native); ignoring call.')
            return
        end

        SetEntityOrphanMode(self.handle, mode)
    end

    ---@protected
    ---@param spawn fun(modelHash: number, data: table): number Native spawner returning the entity handle.
    ---@param data table Spawn data; `data.model` may be a string or precomputed hash.
    ---@param assetType string Label used in error messages (`'object'`, `'ped'`, `'vehicle'`).
    ---@return number handle
    ---@return number modelHash
    function Entity.createServer(spawn, data, assetType)
        local modelHash = type(data.model) == 'number' and data.model or joaat(data.model) --[[@as number]]
        local handle = spawn(modelHash, data)

        if handle == 0 then
            error(('failed to spawn %s %s'):format(assetType, data.model), 3)
        end

        local ok, err = pcall(lib.waitFor, function()
            if DoesEntityExist(handle) then return true end
        end, ('%s %s did not materialize'):format(assetType, data.model), 5000)

        if not ok then
            lib.print.error(err)
            if DoesEntityExist(handle) then DeleteEntity(handle) end
            error(('%s failed to spawn within timeout'):format(assetType), 3)
        end

        return handle, modelHash
    end

    ---Registers the client→server spawn proxy callback for a subclass.
    ---When `ox:allowClientServerEntityCreation` is enabled, the callback constructs
    ---@param cls table Subclass to instantiate (e.g. `ObjectServer`).
    ---@param callbackName string Callback identifier, e.g. `'ox_lib:createObject'`.
    ---@param assetType string Label used in warnings (`'object'`, `'ped'`, `'vehicle'`).
    function Entity.registerCreateCallback(cls, callbackName, assetType)
        lib.callback.register(callbackName, function(source, data)
            if not allowClientServerEntityCreation then
                lib.print.warn(('player %d attempted server-side %s spawn but convar is disabled'):format(source, assetType))
                return nil
            end

            local ok, instance = pcall(cls.new, cls, data)
            if not ok then
                lib.print.error(instance)
                return nil
            end

            return instance:getNetworkId()
        end)
    end
else
    local allowClientEntityCreation = GetConvarInt('ox:allowClientEntityCreation', 0) == 1
    local allowClientServerEntityCreation = GetConvarInt('ox:allowClientServerEntityCreation', 0) == 1

    ---@return boolean
    function Entity:isNetworked()
        return NetworkGetEntityIsNetworked(self.handle)
    end

    ---@return number? networkId nil if the entity is not networked.
    function Entity:getNetworkId()
        if not NetworkGetEntityIsNetworked(self.handle) then return nil end
        return NetworkGetNetworkIdFromEntity(self.handle)
    end

    ---@protected
    ---Shared client spawn flow used by `lib.object`, `lib.ped`, and `lib.vehicle`.
    ---@param spawn fun(modelHash: number, data: table): number Native spawner used for local creation.
    ---@param data table Spawn data forwarded to the server callback or to `spawn`.
    ---@param callbackName string Server callback identifier, e.g. `'ox_lib:createObject'`.
    ---@param assetType string Label used in error messages (`'object'`, `'ped'`, `'vehicle'`).
    ---@return number handle
    ---@return number? modelHash
    function Entity.createClient(spawn, data, callbackName, assetType)
        local wantsNetwork = data.isNetwork == true

        if wantsNetwork and not allowClientEntityCreation then
            error(('client-side networked %s creation is disabled (set `ox:allowClientEntityCreation`)'):format(assetType), 3)
        end

        local useProxy = wantsNetwork and allowClientServerEntityCreation
        local handle, modelHash

        if useProxy then
            local netId = lib.callback.await(callbackName, false, data)
            if not netId or netId == 0 then
                error(('server refused or failed to spawn %s %s'):format(assetType, data.model), 3)
            end

            local ok, syncedHandle = pcall(lib.waitFor, function()
                local h = NetworkGetEntityFromNetworkId(netId)
                if h ~= 0 and DoesEntityExist(h) then return h end
            end, ('%s netId %s did not sync to client'):format(assetType, netId), 5000)

            if not ok then
                lib.print.error(syncedHandle)
            end

            handle = ok and syncedHandle or 0
            modelHash = handle ~= 0 and GetEntityModel(handle) or nil
        else
            modelHash = lib.requestModel(data.model, 10000)
            handle = spawn(modelHash, data)
            SetModelAsNoLongerNeeded(modelHash)
        end

        if handle == 0 or not DoesEntityExist(handle) then
            error(('failed to spawn %s %s'):format(assetType, data.model), 3)
        end

        return handle, modelHash
    end
end

lib.entity = Entity

return lib.entity
