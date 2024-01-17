---Yields the current thread until a non-nil value is returned by the function.  
---Errors after timeout (default 1000) iterations.
---@generic T
---@param cb fun(): T?
---@param errMessage string?
---@param timeout number?
---@return T?
---@async
function lib.waitFor(cb, errMessage, timeout)
    local value = cb()

    if value ~= nil then return value end

    timeout = tonumber(timeout) or 1000

    if IsDuplicityVersion() then
        timeout /= 50;
    else
        timeout -= GetFrameTime() * 1000;
    end

    local start = GetGameTimer()
    local i = 0

    while value == nil do
        if timeout then
            i += 1

            if i > timeout then return error(('%s (waited %.1fms)'):format(errMessage or 'failed to resolve callback', (GetGameTimer() - start) / 1000), 2) end
        end

        Wait(0)
        value = cb()
    end

    return value
end

return lib.waitFor
