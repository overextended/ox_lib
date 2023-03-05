---Load a weapon asset. When called from a thread, it will yield until it has loaded.
---@param weaponHash string | number
---@param timeout number? Number of ticks to wait for the asset to load. Default is 500.
---@return string | number? weaponHash
function lib.requestWeaponAsset(weaponHash, timeout)
    if HasWeaponAssetLoaded(weaponHash) then return weaponHash end

    local weaponHashType = type(weaponHash)
    if weaponHashType ~= 'string' and weaponHashType ~= "number" then
        error(("expected weaponHash to have type 'string' (received %s)"):format(weaponHashType))
    end

    RequestWeaponAsset(weaponHash, 31, 0)

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
