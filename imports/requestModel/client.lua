---Load a model. When called from a thread, it will yield until it has loaded.
---@param model number | string
---@param timeout number? Approximate milliseconds to wait for the model to load. Default is 10000.
---@return number model
function lib.requestModel(model, timeout)
    if type(model) ~= 'number' then model = joaat(model) end
    if HasModelLoaded(model) then return model end

    if not IsModelValid(model) then
        error(("attempted to load invalid model '%s'"):format(model))
    end

    return lib.streamingRequest(RequestModel, HasModelLoaded, 'model', model, timeout)
end

return lib.requestModel
