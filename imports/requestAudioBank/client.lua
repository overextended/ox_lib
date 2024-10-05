---Loads an audio bank.
---@param audioBank string
---@param timeout number?
---@return string
function lib.requestAudioBank(audioBank, timeout)
    return lib.waitFor(function()
        if RequestScriptAudioBank(audioBank, false) then return audioBank end
    end, ("failed to load audiobank '%s' - this may be caused by\n- too many loaded assets\n- oversized, invalid, or corrupted assets"):format(audioBank), timeout or 30000)
end

return lib.requestAudioBank
