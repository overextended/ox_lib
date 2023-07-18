---Load a named particle effect. When called from a thread, it will yield until it has loaded.
---@param ptFxName string
---@param timeout number? Number of ticks to wait for the particle effect to load. Default is 500.
---@return string? ptFxName
function lib.requestNamedPtfxAsset(ptFxName, timeout)
    if HasNamedPtfxAssetLoaded(ptFxName) then return ptFxName end

    if type(ptFxName) ~= 'string' then
        error(("expected ptFxName to have type 'string' (received %s)"):format(type(ptFxName)))
    end

    RequestNamedPtfxAsset(ptFxName)

    if coroutine.isyieldable() then
        timeout = tonumber(timeout) or 500

        for _ = 1, timeout do
            if HasNamedPtfxAssetLoaded(ptFxName) then
                return ptFxName
            end

            Wait(0)
        end

        print(("failed to load ptFxName '%s' after %s ticks"):format(ptFxName, timeout))
    end

    return ptFxName
end

return lib.requestNamedPtfxAsset
