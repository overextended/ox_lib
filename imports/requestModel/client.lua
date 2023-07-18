---Load a model. When called from a thread, it will yield until it has loaded.
---@param model number | string
---@param timeout number? Number of ticks to wait for the model to load. Default is 500.
---@return number? model
function lib.requestModel(model, timeout)
    if not tonumber(model) then model = joaat(model) end
    ---@cast model -string
    if HasModelLoaded(model) then return model end

    if not IsModelValid(model) then
        return error(("attempted to load invalid model '%s'"):format(model))
    end

    RequestModel(model)

    if coroutine.isyieldable() then
        timeout = tonumber(timeout) or 500

        for _ = 1, timeout do
            if HasModelLoaded(model) then
                return model
            end

            Wait(0)
        end

        print(("failed to load model '%s' after %s ticks"):format(model, timeout))
    end

    return model
end

return lib.requestModel
