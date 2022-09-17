local progress
local DisableControlAction = DisableControlAction
local DisablePlayerFiring = DisablePlayerFiring
local playerState = LocalPlayer.state

---@class ProgressPropProps
---@field model string
---@field bone? number
---@field pos vector3
---@field rot vector3

---@class ProgressProps
---@field label? string
---@field duration number
---@field position? 'middle' | 'bottom'
---@field useWhileDead? boolean
---@field allowRagdoll? boolean
---@field allowCuffed? boolean
---@field allowFalling? boolean
---@field canCancel? boolean
---@field anim? { dict?: string, clip: string, flag?: number, blendIn?: number, blendOut?: number, duration?: number, playbackRate?: number, lockX?: boolean, lockY?: boolean, lockZ?: boolean, scenario?: string, playEnter?: boolean }
---@field prop? ProgressPropProps | ProgressPropProps[]
---@field disable? { move?: boolean, car?: boolean, combat?: boolean, mouse?: boolean }

local function createProp(prop)
    lib.requestModel(prop.model)
    local coords = GetEntityCoords(cache.ped)
    local object = CreateObject(prop.model, coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(object, cache.ped, GetPedBoneIndex(cache.ped, prop.bone or 60309), prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, true, true, false, true, 0, true)
    return object
end

local function interruptProgress(data)
    if not data.useWhileDead and IsEntityDead(cache.ped) then return true end
    if not data.allowRagdoll and IsPedRagdoll(cache.ped) then return true end
    if not data.allowCuffed and IsPedCuffed(cache.ped) then return true end
    if not data.allowFalling and IsPedFalling(cache.ped) then return true end
end

local function startProgress(data)
    playerState.invBusy = true
    progress = data

    if data.anim then
        if data.anim.dict then
            lib.requestAnimDict(data.anim.dict)
            TaskPlayAnim(cache.ped, data.anim.dict, data.anim.clip, data.anim.blendIn or 3.0, data.anim.blendOut or 1.0, data.anim.duration or -1, data.anim.flag or 49, data.anim.playbackRate or 0, data.anim.lockX, data.anim.lockY, data.anim.lockZ)
            data.anim = true
        elseif data.anim.scenario then
            TaskStartScenarioInPlace(cache.ped, data.anim.scenario, 0, data.anim.playEnter ~= nil and data.anim.playEnter or true)
            data.anim = true
        end
    end

    if data.prop then
        if data.prop.model then
            data.prop1 = createProp(data.prop)
        else
            for i = 1, #data.prop do
                local prop = data.prop[i]

                if prop then
                    data['prop'..i] = createProp(prop)
                end
            end
        end
    end

    local disable = data.disable

    while progress do
        if disable then
            if disable.mouse then
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 106, true)
            end

            if disable.move then
                DisableControlAction(0, 21, true)
                DisableControlAction(0, 30, true)
                DisableControlAction(0, 31, true)
                DisableControlAction(0, 36, true)
            end

            if disable.car then
                DisableControlAction(0, 63, true)
                DisableControlAction(0, 64, true)
                DisableControlAction(0, 71, true)
                DisableControlAction(0, 72, true)
                DisableControlAction(0, 75, true)
            end

            if disable.combat then
                DisableControlAction(0, 25, true)
                DisablePlayerFiring(cache.playerId, true)
            end
        end

        if interruptProgress(progress) then
            progress = false
        end

        Wait(0)
    end

    if data.anim then
        ClearPedTasks(cache.ped)
    end

    if data.prop then
        local n = #data.prop
        for i = 1, n > 0 and n or 1 do
            local prop = data['prop'..i]

            if prop then
                DeleteEntity(prop)
            end
        end
    end

    playerState.invBusy = false
    local cancel = progress == false
    progress = nil

    if cancel then
        SendNUIMessage({ action = 'progressCancel' })
        return false
    end

    return true
end

---@param data ProgressProps
---@return boolean?
function lib.progressBar(data)
    while progress ~= nil do Wait(100) end

    if not interruptProgress(data) then
        SendNUIMessage({
            action = 'progress',
            data = {
                label = data.label,
                duration = data.duration
            }
        })

        return startProgress(data)
    end
end

---@param data ProgressProps
---@return boolean?
function lib.progressCircle(data)
    while progress ~= nil do Wait(100) end

    if not interruptProgress(data) then
        SendNUIMessage({
            action = 'circleProgress',
            data = {
                duration = data.duration,
                position = data.position,
                label = data.label
            }
        })

        return startProgress(data)
    end
end

function lib.cancelProgress()
    if not progress then
        error('No progress bar is active')
    elseif not progress.canCancel then
        error('Progress bar cannot be cancelled')
    end

    progress = false
end

---@return boolean
function lib.progressActive()
    return progress and true
end

RegisterNUICallback('progressComplete', function(data, cb)
    cb(1)
    progress = nil
end)

RegisterCommand('cancelprogress', function()
    if progress?.canCancel then progress = false end
end)

RegisterKeyMapping('cancelprogress', 'Cancel current progress bar', 'keyboard', 'x')
