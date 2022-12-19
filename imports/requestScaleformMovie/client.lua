---Load a scaleform movie. When called from a thread, it will yield until it has loaded.
---@param scaleformName string
---@param timeout number? Number of ticks to wait for the scaleform movie to load. Default is 500.
---@return string? scaleformName
function lib.requestScaleformMovie(scaleformName, timeout)
    if HasScaleformMovieLoaded(scaleformName) then return scaleformName end

    if type(scaleformName) ~= 'string' then
        error(("expected scaleformName to have type 'string' (received %s)"):format(type(scaleformName)))
    end

    RequestScaleformMovie(scaleformName)

    if coroutine.running() then
        timeout = tonumber(timeout) or 500

        for _ = 1, timeout do
            if HasScaleformMovieLoaded(scaleformName) then
                return scaleformName
            end

            Wait(0)
        end

        print(("failed to load scaleformName '%s' after %s ticks"):format(scaleformName, timeout))
    end

    return scaleformName
end

return lib.requestScaleformMovie