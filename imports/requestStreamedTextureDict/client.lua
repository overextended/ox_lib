---Load a texture dictionary. When called from a thread, it will yield until it has loaded.
---@param textureDict string
---@param timeout number? Number of ticks to wait for the dictionary to load. Default is 500.
---@return string? textureDict
function lib.requestStreamedTextureDict(textureDict, timeout)
    if HasStreamedTextureDictLoaded(textureDict) then return textureDict end

    if type(textureDict) ~= 'string' then
        error(("expected textureDict to have type 'string' (received %s)"):format(type(textureDict)))
    end

    RequestStreamedTextureDict(textureDict, false)

    if coroutine.isyieldable() then
        timeout = tonumber(timeout) or 500

        for _ = 1, timeout do
            if HasStreamedTextureDictLoaded(textureDict) then
                return textureDict
            end

            Wait(0)
        end

        print(("failed to load textureDict '%s' after %s ticks"):format(textureDict, timeout))
    end

    return textureDict
end

return lib.requestStreamedTextureDict
