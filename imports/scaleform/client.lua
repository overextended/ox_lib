---@class renderTargetTable
---@field name string
---@field model string|number

---@class detailsTable
---@field name string
---@field fullScreen? boolean
---@field x? number
---@field y? number
---@field width? number
---@field height? number
---@field renderTarget? renderTargetTable

---@class Scaleform : OxClass
---@field scaleform number
---@field draw boolean
---@field target number
---@field targetName string
---@field handle number
---@field fullScreen boolean
lib.scaleform = lib.class('Scaleform')

--- Converts the arguments into data types usable by scaleform
---@param argsTable table
local function convertArgs(argsTable)
    for i=1, #argsTable do
        local arg = argsTable[i]
        if type(arg) == 'string' then
            ScaleformMovieMethodAddParamPlayerNameString(arg)
        elseif type(arg) == 'number' then
            if math.type(arg) == 'integer' then
                ScaleformMovieMethodAddParamInt(arg)
            else
                ScaleformMovieMethodAddParamFloat(arg)
            end
        elseif type(arg) == 'boolean' then
            ScaleformMovieMethodAddParamBool(arg)
        else
            error(('Unsupported Parameter type [%s]'):format(type(arg)))
        end
    end
end

---@param type 'boolean' | 'integer' | 'string'
---@return boolean | integer | string
---@description Awaits the return value, and converts it to a usable data type
local function retrieveReturnValue(type)
    local result = EndScaleformMovieMethodReturnValue()

    lib.waitFor(function()
        if IsScaleformMovieMethodReturnValueReady(result) then
            return true
        end
    end, "Failed to retrieve return value", 1000)

    if type == "integer" then
        return GetScaleformMovieMethodReturnValueInt(result)
    elseif type == "boolean" then
        return GetScaleformMovieMethodReturnValueBool(result)
    else
        return GetScaleformMovieMethodReturnValueString(result)
    end
end

---@param details detailsTable | string
---@return nil
---@description Create a new scaleform class
function lib.scaleform:constructor(details)
    details = type(details) == "table" and details or {name = details}

    local scaleform = lib.requestScaleformMovie(details.name)
    if not scaleform then
        return error(('Failed to request scaleform movie - [%s]'):format(details.name))
    end

    self.handle = scaleform
    self.draw = false

    self.fullScreen = details.fullScreen ~= nil and details.fullScreen or true
    self.x = details.x or 0
    self.y = details.y or 0
    self.width = details.width or 0
    self.height = details.height or 0

    if details.renderTarget then
        self:setRenderTarget(details.renderTarget.name, details.renderTarget.model)
    end
end

---@param name string
---@param args? table
---@param returnValue? string
---@return any
---@description Call a scaleform function, with optional args or return value.
function lib.scaleform:callMethod(name, args, returnValue)
    if not self.handle then
        return error('Scaleform handle is nil')
    end

    if args and type(args) ~= 'table' then
        return error('Args must be a table')
    end

    BeginScaleformMovieMethod(self.handle, name)

    if args then
        convertArgs(args)
    end

    if returnValue then
        return retrieveReturnValue(returnValue)
    end

    EndScaleformMovieMethod()
end

---@param isFullscreen boolean
---@return nil
---@description Set the scaleform to render in full screen
function lib.scaleform:setFullScreen(isFullscreen)
    self.fullScreen = isFullscreen
end

---@param x number
---@param y number
---@param width number
---@param height number
---@return nil
---@description Set the properties of the scaleform (Requires SetFullScreen to be false)
function lib.scaleform:setProperties(x, y, width, height)
    if self.fullScreen then
        return error('Cannot set properties when full screen is enabled')
    end

    self.x = x
    self.y = y
    self.width = width
    self.height = height
end

---@param name string
---@param model string|number
---@return nil
---@description Create a render target for the scaleform - optional , only if you want to render the scaleform in 3D
function lib.scaleform:setRenderTarget(name, model)
    if self.target then
        ReleaseNamedRendertarget(self.targetName)
    end

    if type(model) == 'string' then
        model = joaat(model)
    end

    if not IsNamedRendertargetRegistered(name) then
        RegisterNamedRendertarget(name, false)

        if not IsNamedRendertargetLinked(model) then
            LinkNamedRendertarget(model)
        end

        self.target = GetNamedRendertargetRenderId(name)
        self.targetName = name
    end
end

---@return nil
---@description Set The Scaleform to draw
function lib.scaleform:startDrawing()
    if self.draw then
        return error("Scaleform Already Drawing")
    end

    self.draw = true
    CreateThread(function()
        while self.draw do
            if self.target then
                SetTextRenderId(self.target)
                SetScriptGfxDrawOrder(4)
                SetScriptGfxDrawBehindPausemenu(true)
                SetScaleformFitRendertarget(self.handle, true)
            end

            if self.fullScreen then
                DrawScaleformMovieFullscreen(self.handle, 255, 255, 255, 255, 0)
            else
                if not self.x or not self.y or not self.width or not self.height then
                    error('Properties not set for scaleform')
                    DrawScaleformMovieFullscreen(self.handle, 255, 255, 255, 255, 0)
                else
                    DrawScaleformMovie(self.handle, self.x, self.y, self.width, self.height, 255, 255, 255, 255, 0)
                end
            end

            if self.target then
                SetTextRenderId(1)
            end

            Wait(0)
        end
    end)
end

---@return nil
---@description stop the scaleform from drawing, use this to only temporarily disable it, use Dispose otherwise.
function lib.scaleform:stopDrawing()
    if not self.draw then
        return
    end
    self.draw = false
end

---@return nil
---@description Disposes of the scaleform and reset the values
function lib.scaleform:dispose()
    if self.handle then
        SetScaleformMovieAsNoLongerNeeded(self.handle)
    end

    if self.target then
        ReleaseNamedRendertarget(self.targetName)
    end

    self.handle = nil
    self.target = nil
    self.draw = false
end

---@return Scaleform
return lib.scaleform