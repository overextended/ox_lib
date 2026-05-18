--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class Object : GameEntity
---@field private new ObjectConstructor
lib.object = lib.class('Object', lib.gameEntity)

---@class ObjectConstructor
---@overload fun(self: Object, handle: number): Object
function lib.object:constructor(handle)
    self:super()
    self:setHandle(handle)
end

function lib.object:__index(index)
    if index == 'handle' then
        return self.private.handle
    end

    return lib.object[index]
end

return lib.object
