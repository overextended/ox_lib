local function request(native, hasLoaded, requestType, name, timeout)
	native(name)

	if coroutine.running() then
		if not timeout then
			timeout = 500
		end

		for i = 1, timeout do
			Wait(0)
			if hasLoaded(name) then
				return name
			end
		end

		print(("Failed to load %s '%s' after %s ticks"):format(requestType, name, timeout))
	end

	return name
end

---Load an animation dictionary. When called from a thread, it will yield until it has loaded.
---@param animDict string
---@param timeout number? Number of ticks to wait for the dictionary to load. Default is 500.
---@return string? animDict
function lib.requestAnimDict(animDict, timeout)
	if HasAnimDictLoaded(animDict) then return animDict end

	if not DoesAnimDictExist(animDict) then
		return error(("Attempted to load invalid animDict (%s)"):format(animDict))
	end

	return request(RequestAnimDict, HasAnimDictLoaded, 'animDict', animDict, timeout)
end

---Load an animation clipset. When called from a thread, it will yield until it has loaded.
---@param animSet string
---@param timeout number? Number of ticks to wait for the clipset to load. Default is 500.
---@return string? animSet
function lib.requestAnimSet(animSet, timeout)
	if HasAnimSetLoaded(animSet) then return animSet end
	return request(RequestAnimSet, HasAnimSetLoaded, 'animSet', animSet, timeout)
end

---Load a model. When called from a thread, it will yield until it has loaded.
---@param model number
---@param timeout number? Number of ticks to wait for the model to load. Default is 500.
---@return number? model
function lib.requestModel(model, timeout)
	if not tonumber(model) then model = joaat(model) end
	if HasModelLoaded(model) then return model end

	if not IsModelValid(model) then
		return error(("Attempted to load invalid model (%s)"):format(model))
	end

	return request(RequestModel, HasModelLoaded, 'model', model, timeout)
end

---Load a texture dictionary. When called from a thread, it will yield until it has loaded.
---@param textureDict string
---@param timeout number? Number of ticks to wait for the dictionary to load. Default is 500.
---@return string? textureDict
function lib.requestStreamedTextureDict(textureDict, timeout)
	if HasStreamedTextureDictLoaded(textureDict) then return textureDict end
	return request(RequestStreamedTextureDict, HasStreamedTextureDictLoaded, 'textureDict', textureDict, timeout)
end

---Load a named particle effect. When called from a thread, it will yield until it has loaded.
---@param fxName string
---@param timeout number? Number of ticks to wait for the particle effect to load. Default is 500.
---@return string? fxName
function lib.requestNamedPtfxAsset(fxName, timeout)
	if HasNamedPtfxAssetLoaded(fxName) then return fxName end
	return request(RequestNamedPtfxAsset, HasNamedPtfxAssetLoaded, 'fxName', fxName, timeout)
end