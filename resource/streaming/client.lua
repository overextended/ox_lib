---@param dict string
--- Loads an animation dictionary.
function lib.requestAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(0) end
    end
    return true
end

---@param set string
--- Loads an animation clipset.
function lib.requestAnimSet(set)
    if not HasAnimSetLoaded(set) then
        RequestAnimSet(set)
        while not HasAnimSetLoaded(set) do Wait(0) end
    end
    return true
end

---@param model string|number
--- Loads a model.
function lib.requestModel(model)
    model = type(model) == 'number' and model or joaat(model)
    if not HasModelLoaded(model) then
        assert(IsModelValid(model), ('Attempted to load an invalid model (%s)'):format(model))
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end
    end
    return true
end

---@param dict string
--- Loads a texture dictionary.
function lib.requestStreamedTextureDict(dict)
    if not HasStreamedTextureDictLoaded(dict) then
        RequestStreamedTextureDict(dict)
        while not HasStreamedTextureDictLoaded(dict) do Wait(0) end
    end
    return true
end

---@param fxName string
--- Loads a named particle effect.
function lib.requestNamedPtfxAsset(fxName)
    if not HasNamedPtfxAssetLoaded(fxName) then
        RequestNamedPtfxAsset(fxName)
        while not HasNamedPtfxAssetLoaded(fxName) do Wait(0) end
    end
    return true
end