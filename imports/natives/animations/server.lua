local anims = {}

---@param pedId number
---@param dict string
---@param anim string
---@param wait number
---@param blendIn number
---@param blendOut number
---@param duration number
---@param flag number
---@param pbRate number
---@param lockX number
---@param lockY number
---@param lockZ number
anims.playAnim = function(pedId, dict, anim, wait, blendIn, blendOut, duration, flag, pbRate, lockX, lockY, lockZ)
    if pedId == nil then 
        error('\n^1Playing animation failed. pedId was not specified!^0', 3)
        return
    end

    lockX = (lockX ~= nil) and lockX or 0
    lockY = (lockY ~= nil) and lockY or 0
    lockZ = (lockZ ~= nil) and lockZ or 0

    if GetVehiclePedIsIn(pedId, false) then return end

    TaskPlayAnim(pedId, dict, anim, blendIn, blendOut, duration, flag, pbRate, lockX, lockY, lockZ)

    Wait(wait ~= nil and wait or 0)

    if wait > 0 then ClearPedSecondaryTask(pedId) end
end

---@param pedId number
---@param dict string
---@param anim string
---@param wait number
---@param posX number
---@param posY number
---@param posZ number
---@param rotX number
---@param rotY number
---@param rotZ number
---@param blendIn number
---@param blendOut number
---@param duration number
---@param flag number
---@param pbRate number
anims.playAdvancedAnim = function(pedId, dict, anim, wait, posX, posY, posZ, rotX, rotY, rotZ, blendIn, blendOut, duration, flag, pbRate)
    if pedId == nil then 
        error('\n^1Playing animation failed. pedId was not specified!^0', 3)
        return
    end

    if GetVehiclePedIsIn(pedId, false) then return end

    TaskPlayAnimAdvanced(pedId, dict, anim, posX, posY, posZ, rotX, rotY, rotZ, blendIn, blendOut, duration, flag, pbRate, false, false)

    Wait(wait ~= nil and wait or 0)

    if wait > 0 then ClearPedSecondaryTask(pedId) end
end

return anims