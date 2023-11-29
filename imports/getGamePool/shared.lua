local poolNames = {
    CPed = "GetAllPeds",
    CObject = "GetAllObjects",
    CVehicle = "GetAllVehicles"
}

function lib.getGamePool(pool)
    if lib.context == "client" then
        return GetGamePool(pool)
    end
    local poolNative = poolNames[pool]
    if not poolNative or not _G[poolNative] then return end
    return _G[poolNative]()
end

return lib.getGamePool
