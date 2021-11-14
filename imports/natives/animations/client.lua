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
    pedId = (pedId ~= nil) and pedId or PlayerPedId()
    lockX = (lockX ~= nil) and lockX or 0
    lockY = (lockY ~= nil) and lockY or 0
    lockZ = (lockZ ~= nil) and lockZ or 0

    if GetVehiclePedIsIn(pedId, false) then return end

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
    
    TaskPlayAnim(pedId, dict, anim, blendIn, blendOut, duration, flag, pbRate, lockX, lockY, lockZ)

    Wait(wait ~= nil and wait or 0)

    if wait > 0 then ClearPedSecondaryTask(pedId) end
    
    RemoveAnimDict(dict)
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
    pedId = (pedId ~= nil) and pedId or PlayerPedId()

    if GetVehiclePedIsIn(pedId, false) then return end

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end

    TaskPlayAnimAdvanced(pedId, dict, anim, posX, posY, posZ, rotX, rotY, rotZ, blendIn, blendOut, duration, flag, pbRate, false, false)

    Wait(wait ~= nil and wait or 0)

    if wait > 0 then ClearPedSecondaryTask(pedId) end

    RemoveAnimDict(dict)
end

return anims