---@alias AnimationFlags number
---| 0 DEFAULT
---| 1 LOOPING
---| 2 HOLD_LAST_FRAME
---| 4 REPOSITION_WHEN_FINISHED
---| 8 NOT_INTERRUPTABLE
---| 16 UPPERBODY
---| 32 SECONDARY
---| 64 REORIENT_WHEN_FINISHED
---| 128 ABORT_ON_PED_MOVEMENT
---| 256 ADDITIVE
---| 512 TURN_OFF_COLLISION
---| 1024 OVERRIDE_PHYSICS
---| 2048 IGNORE_GRAVITY
---| 4096 EXTRACT_INITIAL_OFFSET
---| 8192 EXIT_AFTER_INTERRUPTED
---| 16384 TAG_SYNC_IN
---| 32768 TAG_SYNC_OUT
---| 65536 TAG_SYNC_CONTINUOUS
---| 131072 FORCE_START
---| 262144 USE_KINEMATIC_PHYSICS
---| 524288 USE_MOVER_EXTRACTION
---| 1048576 HIDE_WEAPON
---| 2097152 ENDS_IN_DEAD_POSE
---| 4194304 ACTIVATE_RAGDOLL_ON_COLLISION
---| 8388608 DONT_EXIT_ON_DEATH
---| 16777216 ABORT_ON_WEAPON_DAMAGE
---| 33554432 DISABLE_FORCED_PHYSICS_UPDATE
---| 67108864 PROCESS_ATTACHMENTS_ON_START
---| 134217728 EXPAND_PED_CAPSULE_FROM_SKELETON
---| 268435456 USE_ALTERNATIVE_FP_ANIM
---| 536870912 BLENDOUT_WRT_LAST_FRAME
---| 1073741824 USE_FULL_BLENDING

---@alias ControlFlags number
---| 0 NONE
---| 1 DISABLE_LEG_IK
---| 2 DISABLE_ARM_IK
---| 4 DISABLE_HEAD_IK
---| 8 DISABLE_TORSO_IK
---| 16 DISABLE_TORSO_REACT_IK
---| 32 USE_LEG_ALLOW_TAGS
---| 64 USE_LEG_BLOCK_TAGS
---| 128 USE_ARM_ALLOW_TAGS
---| 256 USE_ARM_BLOCK_TAGS
---| 512 PROCESS_WEAPON_HAND_GRIP
---| 1024 USE_FP_ARM_LEFT
---| 2048 USE_FP_ARM_RIGHT
---| 4096 DISABLE_TORSO_VEHICLE_IK
---| 8192 LINKED_FACIAL

---@param ped number
---@param animDictionary string
---@param animationName string
---@param blendInSpeed? number Defaults to 8.0
---@param blendOutSpeed? number Defaults to -8.0
---@param duration? integer Defaults to -1
---@param animFlags? AnimationFlags
---@param startPhase? number
---@param phaseControlled? boolean
---@param controlFlags? integer
---@param overrideCloneUpdate? boolean
function lib.playAnim(ped, animDictionary, animationName, blendInSpeed, blendOutSpeed, duration, animFlags, startPhase, phaseControlled, controlFlags, overrideCloneUpdate)
    lib.requestAnimDict(animDictionary)
    ---@diagnostic disable-next-line: param-type-mismatch
    TaskPlayAnim(ped, animDictionary, animationName, blendInSpeed or 8.0, blendOutSpeed or -8.0, duration or -1, animFlags or 0, startPhase or 0.0, phaseControlled or false, controlFlags or 0, overrideCloneUpdate or false)
    RemoveAnimDict(animDictionary)
end

return lib.playAnim
