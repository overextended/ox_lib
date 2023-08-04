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

    if not coroutine.isyieldable() then return textureDict end

    return lib.waitFor(function()
        if HasStreamedTextureDictLoaded(textureDict) then return textureDict end
    end, ("failed to load textureDict '%s'"):format(textureDict), timeout or 500)
end

return lib.requestStreamedTextureDict
