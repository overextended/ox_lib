---Loads audio bank 
---@param audioBank string
---@param timeout number?
---@return boolean
function lib.requestAudioBank(audioBank, timeout)
    RequestScriptAudioBank(audioBank, false)

    if not coroutine.isyieldable() then return true end
    return lib.waitFor(function()
        if RequestScriptAudioBank(audioBank, false) then return true end
    end, ("failed to load audiobank '%s'"):format(audioBank), timeout or 500)
end

return lib.requestAudioBank