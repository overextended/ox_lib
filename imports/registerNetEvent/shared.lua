---Registers a net event that cannot be called from the same side of the network
---@param event string
---@param fn function
function lib.registerNetEvent(event, fn)
    RegisterNetEvent(event, function(...)
        if source == '' then return end
        fn(...)
    end)
end

return lib.registerNetEvent
