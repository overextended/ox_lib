---@class CDui
---@field id string
---@field debug boolean
---@field url string
---@field duiObject number
---@field duiHandle string
---@field runtimeTxd number
---@field txdObject number
---@field dictName string
---@field txtName string
---@field remove fun(CDui)
---@field setUrl fun(CDui, string)
---@field sendMessage fun(CDui, table)

---@type table<number, CDui>
local duis = {}
local resourceName = GetCurrentResourceName()

---@param self CDui
local function removeDui(self)
    SetDuiUrl(self.duiObject, 'about:blank')
    DestroyDui(self.duiObject)
    duis[self.id] = nil

    if self.debug then
        print(('Dui %s removed'):format(self.id))
    end
end

---@param self CDui
---@param url string
local function setDuiUrl(self, url)
    SetDuiUrl(self.duiObject, url)
end

---@param self CDui
---@param message table
local function sendMessage(self, message)
    SendDuiMessage(self.duiObject, json.encode(message))
end

lib.dui = {
    ---@return CDui
    ---@param url string
    ---@param width number
    ---@param height number
    ---@param debug? boolean
    new = function(url, width, height, debug)
        local self
        local time = GetGameTimer()
        local id = ("%s_%s_%s"):format(resourceName, time, math.random(1, 1000))
        while duis[id] do
            id = ("%s_%s_%s"):format(resourceName, time, math.random(1, 1000))
            Wait(0)
        end
        local dictName = ('ox_lib_dui_dict_%s'):format(id)
        local txtName = ('ox_lib_dui_txt_%s'):format(id)
        local duiObject = CreateDui(url, width, height)
        local duiHandle = GetDuiHandle(duiObject)
        local runtimeTxd = CreateRuntimeTxd(dictName)
        local txdObject = CreateRuntimeTextureFromDuiHandle(runtimeTxd, txtName, duiHandle)
        self = {
            id = id,
            debug = debug or false,
            url = url,
            duiObject = duiObject,
            duiHandle = duiHandle,
            runtimeTxd = runtimeTxd,
            txdObject = txdObject,
            dictName = dictName,
            txtName = txtName,
            setUrl = setDuiUrl,
            sendMessage = sendMessage,
            remove = removeDui
        }

        if self.debug then
            print(('Dui %s created'):format(id))
        end

        duis[id] = self
        return self
    end,
}

AddEventHandler('onResourceStop', function(stoppedResourceName)
    if stoppedResourceName ~= resourceName then return end
    for _, dui in pairs(duis) do
        dui:remove()
    end
end)

return lib.dui
