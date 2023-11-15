if cache.game == 'redm' then return end

local gizmoEnabled = false

local function makeEntityMatrix(entity)
    local f, r, u, a = GetEntityMatrix(entity)
    local view = lib.dataView.ArrayBuffer(60)

    view:SetFloat32(0, r[1])
        :SetFloat32(4, r[2])
        :SetFloat32(8, r[3])
        :SetFloat32(12, 0)
        :SetFloat32(16, f[1])
        :SetFloat32(20, f[2])
        :SetFloat32(24, f[3])
        :SetFloat32(28, 0)
        :SetFloat32(32, u[1])
        :SetFloat32(36, u[2])
        :SetFloat32(40, u[3])
        :SetFloat32(44, 0)
        :SetFloat32(48, a[1])
        :SetFloat32(52, a[2])
        :SetFloat32(56, a[3])
        :SetFloat32(60, 1)

    return view
end

local function applyEntityMatrix(entity, view)
    SetEntityMatrix(entity,
        view:GetFloat32(16), view:GetFloat32(20), view:GetFloat32(24),
        view:GetFloat32(0), view:GetFloat32(4), view:GetFloat32(8),
        view:GetFloat32(32), view:GetFloat32(36), view:GetFloat32(40),
        view:GetFloat32(48), view:GetFloat32(52), view:GetFloat32(56)
    )
end

local function clearEntityDraw(entity)
    if DoesEntityExist(entity) then SetEntityDrawOutline(entity, false) end
end

local function enableGizmo(entity, onLeaveCallback)
    if not gizmoEnabled then
        return LeaveCursorMode()
    end

    local resetPedAlpha = false
    EnterCursorMode()

    if IsEntityAPed(entity) then
        resetPedAlpha = true
        SetEntityAlpha(entity, 200)
    else
        SetEntityDrawOutline(entity, true)
    end
    
    CreateThread(function()
        while gizmoEnabled and DoesEntityExist(entity) do
            Wait(0)
            
            DisableControlAction(0, 24, true) -- lmb
            DisableControlAction(0, 25, true) -- rmb
            DisableControlAction(0, 140, true) -- r
            DisablePlayerFiring(cache.playerId, true)
    
            local matrixBuffer = makeEntityMatrix(entity)
            local changed = Citizen.InvokeNative(0xEB2EDCA2, matrixBuffer:Buffer(), 'Editor1', Citizen.ReturnResultAnyway())
    
            if changed then
                applyEntityMatrix(entity, matrixBuffer)
            end
        end

        LeaveCursorMode()
        clearEntityDraw(entity)
        if resetPedAlpha and DoesEntityExist(entity) then SetEntityAlpha(entity, 255) end
        if onLeaveCallback then onLeaveCallback() end
    end)
end

function lib.gizmo(entity)
    local gizmo = {}
    
    gizmoEnabled = true
    enableGizmo(entity, function()
        gizmoEnabled = false
        if gizmo.onLeaveCallback then
            gizmo.onLeaveCallback()
        end
    end)

    gizmo.onLeave = function(callback)
        gizmo.onLeaveCallback = callback
    end

    gizmo.close = function()
        gizmoEnabled = false
    end

    return gizmo
end

RegisterKeyMapping('+gizmoSelect', 'Selects the currently highlighted gizmo', 'MOUSE_BUTTON', 'MOUSE_LEFT')
RegisterKeyMapping('+gizmoTranslation', 'Sets mode of the gizmo to translation', 'keyboard', 'T')
RegisterKeyMapping('+gizmoRotation', 'Sets mode for the gizmo to rotation', 'keyboard', 'R')
RegisterKeyMapping('+gizmoScale', 'Sets mode for the gizmo to scale', 'keyboard', 'S')
RegisterKeyMapping('+gizmoLocal', 'Sets gizmo to be local to the entity instead of world', 'keyboard', 'L')

return lib.gizmo