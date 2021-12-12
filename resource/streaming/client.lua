local function hasLoaded(fn, lType, name, limit)
	local timeout = limit
	while not fn(name) do
		Wait(0)
		if timeout then
			timeout -= 1
			if timeout == 0 then
				print(('Unable to load %s after %s ticks (%s)'):format(lType, limit, name))
				return false
			end
		end
	end
	return name
end

---@param dict string
---@param timeout number
--- Loads an animation dictionary.
function lib.requestAnimDict(dict, timeout)
	if HasAnimDictLoaded(dict) then return dict end
	assert(DoesAnimDictExist(dict), ('Attempted to load an invalid animdict (%s)'):format(dict))
	RequestAnimDict(dict)
	return hasLoaded(HasModelLoaded, 'animdict', dict, timeout)
end

---@param set string
---@param timeout number
--- Loads an animation clipset.
function lib.requestAnimSet(set, timeout)
	if HasAnimSetLoaded(set) then return set end
	RequestAnimSet(set)
	return hasLoaded(HasModelLoaded, 'animset', set, timeout)
end

---@param model string|number
---@param timeout number
--- Loads a model.
function lib.requestModel(model, timeout)
	model = tonumber(model) or joaat(model)
	if HasModelLoaded(model) then return model end
	assert(IsModelValid(model), ('Attempted to load an invalid model (%s)'):format(model))
	RequestModel(model)
	return hasLoaded(HasModelLoaded, 'model', model, timeout)
end

---@param dict string
---@param timeout number
--- Loads a texture dictionary.
function lib.requestStreamedTextureDict(dict, timeout)
	if HasStreamedTextureDictLoaded(dict) then return dict end
	RequestStreamedTextureDict(dict)
	return hasLoaded(HasModelLoaded, 'texture dict', dict, timeout)
end

---@param fxName string
---@param timeout number
--- Loads a named particle effect.
function lib.requestNamedPtfxAsset(fxName, timeout)
	if HasNamedPtfxAssetLoaded(fxName) then return fxName end
	RequestNamedPtfxAsset(fxName)
	return hasLoaded(HasModelLoaded, 'named ptfx', fxName, timeout)
end