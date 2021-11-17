local function hasLoaded(fn, name)
	local timeout = 0
	while not fn(name) do
		Wait(0)
		timeout += 1
		if timeout > 20 then return false end
	end
	return true
end

---@param dict string
--- Loads an animation dictionary.
function lib.requestAnimDict(dict)
	if HasAnimDictLoaded(dict) then return true end
	assert(DoesAnimDictExist(dict), ('Attempted to load an invalid animdict (%s)'):format(dict))
	RequestAnimDict(dict)
	if hasLoaded(HasAnimDictLoaded, dict) then return true end
	print(('Unable to load animdict after 20 ticks (%s)'):format(dict))
end

---@param set string
--- Loads an animation clipset.
function lib.requestAnimSet(set)
	if HasAnimSetLoaded(set) then return true end
	RequestAnimSet(set)
	if hasLoaded(HasAnimSetLoaded, set) then return true end
	print(('Unable to load animset after 20 ticks (%s)'):format(set))
end

---@param model string|number
--- Loads a model.
function lib.requestModel(model)
	model = type(model) == 'number' and model or joaat(model)
	if HasModelLoaded(model) then return true end
	assert(IsModelValid(model), ('Attempted to load an invalid model (%s)'):format(model))
	RequestModel(model)
	if hasLoaded(HasModelLoaded, model) then return true end
	print(('Unable to load model after 20 ticks (%s)'):format(model))
end

---@param dict string
--- Loads a texture dictionary.
function lib.requestStreamedTextureDict(dict)
	if HasStreamedTextureDictLoaded(dict) then return true end
	RequestStreamedTextureDict(dict)
	if hasLoaded(HasStreamedTextureDictLoaded, dict) then return true end
	print(('Unable to load texture dict after 20 ticks (%s)'):format(dict))
end

---@param fxName string
--- Loads a named particle effect.
function lib.requestNamedPtfxAsset(fxName)
	if HasNamedPtfxAssetLoaded(fxName) then return true end
	RequestNamedPtfxAsset(fxName)
	if hasLoaded(RequestNamedPtfxAsset, fxName) then return true end
	print(('Unable to load named ptfx after 20 ticks (%s)'):format(fxName))
end