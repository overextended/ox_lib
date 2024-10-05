---@async
---@generic T : string | number
---@param request function
---@param hasLoaded function
---@param assetType string
---@param asset T
---@param timeout? number
---@param ... any
---Used internally.
function lib.streamingRequest(request, hasLoaded, assetType, asset, timeout, ...)
    if hasLoaded(asset) then return asset end

    request(asset, ...)

    return lib.waitFor(function()
            if hasLoaded(asset) then return asset end
        end, ("failed to load %s '%s' - this may be caused by\n- too many loaded assets\n- oversized, invalid, or corrupted assets"):format(assetType, asset),
        timeout or 30000)
end

return lib.streamingRequest
