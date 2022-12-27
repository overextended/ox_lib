---Load a scaleform movie. When called from a thread, it will yield until it has loaded.
---@param scaleformName string
---@param timeout number? Number of ticks to wait for the scaleform movie to load. Default is 500.
---@return number? scaleform
function lib.requestScaleformMovie(scaleformName, timeout)
    if type(scaleformName) ~= 'string' then
        error(("expected scaleformName to have type 'string' (received %s)"):format(type(scaleformName)))
    end

    local scaleform = RequestScaleformMovie(scaleformName)

    if HasScaleformMovieLoaded(scaleform) then return scaleform end

    if coroutine.running() then
        timeout = tonumber(timeout) or 500

        for _ = 1, timeout do
            if HasScaleformMovieLoaded(scaleform) then
                return scaleform
            end

            Wait(0)
        end

        print(("failed to load scaleformName '%s' after %s ticks"):format(scaleformName, timeout))
    end

    return scaleform
end

return lib.requestScaleformMovie