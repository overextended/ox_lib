---Load a scaleform movie. When called from a thread, it will yield until it has loaded.
---@param scaleformName string
---@param timeout number? Approximate milliseconds to wait for the scaleform movie to load. Default is 1000.
---@return number? scaleform
function lib.requestScaleformMovie(scaleformName, timeout)
    if type(scaleformName) ~= 'string' then
        error(("expected scaleformName to have type 'string' (received %s)"):format(type(scaleformName)))
    end

    local scaleform = RequestScaleformMovie(scaleformName)

    if not coroutine.isyieldable() then return scaleform end

    return lib.waitFor(function()
        if HasScaleformMovieLoaded(scaleform) then return scaleform end
    end, ("failed to load scaleform '%s'"):format(scaleform), timeout)
end

return lib.requestScaleformMovie
