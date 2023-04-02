---Load a weapon asset. When called from a thread, it will yield until it has loaded.
---@param weaponHash string | number
---@param timeout number? Number of ticks to wait for the asset to load. Default is 500.
---@param p1 number? Unknown. Default is 31.
---@param p2 number? Unknown. Default is 0.
---@return string | number? weaponHash
function lib.requestWeaponAsset(weaponHash, timeout, p1, p2)
    if HasWeaponAssetLoaded(weaponHash) then return weaponHash end

    local weaponHashType = type(weaponHash)
    if weaponHashType ~= 'string' and weaponHashType ~= "number" then
        error(("expected weaponHash to have type 'string' or 'number' (received %s)"):format(weaponHashType))
    end

    p1 = p1 or 31
    p2 = p2 or 0

    if type(p1) ~= 'number' then
        error(("expected p1 to have type 'number' (received %s)"):format(type(p1)))
    end

    if type(p2) ~= 'number' then
        error(("expected p2 to have type 'number' (received %s)"):format(type(p2)))
    end

    RequestWeaponAsset(weaponHash, p1, p2)

    if coroutine.running() then
        timeout = tonumber(timeout) or 500

        for _ = 1, timeout do
            if HasWeaponAssetLoaded(weaponHash) then
                return weaponHash
            end

            Wait(0)
        end

        print(("failed to load weaponHash '%s' after %s ticks"):format(weaponHash, timeout))
    end

    return weaponHash
end

return lib.requestWeaponAsset
