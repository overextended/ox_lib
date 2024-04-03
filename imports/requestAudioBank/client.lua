---Loads an audio bank.
---@param audioBank string
---@param timeout number?
---@return string
function lib.requestAudioBank(audioBank, timeout)
    return lib.waitFor(function()
        if RequestScriptAudioBank(audioBank, false) then return audioBank end
    end, ("failed to load audiobank '%s'"):format(audioBank), timeout or 500)
end

return lib.requestAudioBank
