local onServer = IsDuplicityVersion()
local poolNames = {
    CPed = "GetAllPeds",
    CObject = "GetAllObjects",
    CVehicle = "GetAllVehicles"
}

function lib.getGamePool(pool)
    if not onServer then
        return GetGamePool(pool)
    end
    local poolNative = poolNames[pool]
    if not poolNative or not _G[poolNative] then return end
    return _G[poolNative]()
end

return lib.getGamePool
