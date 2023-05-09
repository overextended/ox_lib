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
    SetModelAsNoLongerNeeded(prop.model)

    return object
end

local function interruptProgress(data)
    if not data.useWhileDead and IsEntityDead(cache.ped) then return true end
    if not data.allowRagdoll and IsPedRagdoll(cache.ped) then return true end
    if not data.allowCuffed and IsPedCuffed(cache.ped) then return true end
    if not data.allowFalling and IsPedFalling(cache.ped) then return true end
end

local isFivem = cache.game == 'fivem'

local controls = {
    INPUT_LOOK_LR = isFivem and 1 or 0xA987235F,
    INPUT_LOOK_UD = isFivem and 2 or 0xD2047988,
    INPUT_SPRINT = isFivem and 21 or 0x8FFC75D6,
    INPUT_AIM = isFivem and 25 or 0xF84FA74F,
    INPUT_MOVE_LR = isFivem and 30 or 0x4D8FB4C1,
    INPUT_MOVE_UD = isFivem and 31 or 0xFDA83190,
    INPUT_DUCK = isFivem and 36 or 0xDB096B85,
    INPUT_VEH_MOVE_LEFT_ONLY = isFivem and 63 or 0x9DF54706,
    INPUT_VEH_MOVE_RIGHT_ONLY = isFivem and 64 or 0x97A8FD98,
    INPUT_VEH_ACCELERATE = isFivem and 71 or 0x5B9FD4E2,
    INPUT_VEH_BRAKE = isFivem and 72 or 0x6E1F639B,
    INPUT_VEH_EXIT = isFivem and 75 or 0xFEFAB9B4,
    INPUT_VEH_MOUSE_CONTROL_OVERRIDE = isFivem and 106 or 0x39CCABD5
}

local function startProgress(data)
    playerState.invBusy = true
    progress = data
    local anim = data.anim

    if anim then
        if anim.dict then
            lib.requestAnimDict(anim.dict)

            TaskPlayAnim(cache.ped, anim.dict, anim.clip, anim.blendIn or 3.0, anim.blendOut or 1.0, anim.duration or -1, anim.flag or 49, anim.playbackRate or 0, anim.lockX, anim.lockY, anim.lockZ)
            RemoveAnimDict(anim.dict)
        elseif anim.scenario then
            TaskStartScenarioInPlace(cache.ped, anim.scenario, 0, anim.playEnter ~= nil and anim.playEnter or true)
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
                DisableControlAction(0, controls.INPUT_LOOK_LR, true)
                DisableControlAction(0, controls.INPUT_LOOK_UD, true)
                DisableControlAction(0, controls.INPUT_VEH_MOUSE_CONTROL_OVERRIDE, true)
            end

            if disable.move then
                DisableControlAction(0, controls.INPUT_SPRINT, true)
                DisableControlAction(0, controls.INPUT_MOVE_LR, true)
                DisableControlAction(0, controls.INPUT_MOVE_UD, true)
                DisableControlAction(0, controls.INPUT_DUCK, true)
            end

            if disable.car then
                DisableControlAction(0, controls.INPUT_VEH_MOVE_LEFT_ONLY, true)
                DisableControlAction(0, controls.INPUT_VEH_MOVE_RIGHT_ONLY, true)
                DisableControlAction(0, controls.INPUT_VEH_ACCELERATE, true)
                DisableControlAction(0, controls.INPUT_VEH_BRAKE, true)
                DisableControlAction(0, controls.INPUT_VEH_EXIT, true)
            end

            if disable.combat then
                DisableControlAction(0, controls.INPUT_AIM, true)
                DisablePlayerFiring(cache.playerId, true)
            end
        end

        if interruptProgress(progress) then
            progress = false
        end

        Wait(0)
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

    if anim then
        if anim.dict then
            StopAnimTask(cache.ped, anim.dict, anim.clip, 1.0)
            Wait(0) -- This is needed here otherwise the StopAnimTask is cancelled
        else
            ClearPedTasks(cache.ped)
        end
    end

    playerState.invBusy = false

    if progress == false then
        SendNUIMessage({ action = 'progressCancel' })
        return false
    end

    return true
end

---@param data ProgressProps
---@return boolean?
function lib.progressBar(data)
    while progress ~= nil do Wait(0) end

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
    while progress ~= nil do Wait(0) end

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
