---Loads an anim dictionary if it has not been loaded.
---Invalid anim dictionaries will never return.
---@param dict string
return function(dict)
	if not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)
		repeat Wait(0) until HasAnimDictLoaded(dict)
	end
end