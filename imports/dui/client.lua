---@class DuiProperties
---@field url string
---@field width number
---@field height number
---@field debug? boolean

---@class Dui : OxClass
---@field id string
---@field debug boolean
---@field url string
---@field duiObject number
---@field duiHandle string
---@field runtimeTxd number
---@field txdObject number
---@field dictName string
---@field txtName string
lib.dui = lib.class('Dui')

---@type table<string, Dui>
local duis = {}

---@param data DuiProperties
function lib.dui:constructor(data)
    local time = GetGameTimer()
    local id = ("%s_%s_%s"):format(cache.resource, time, math.random(1, 1000))
    while duis[id] do
        id = ("%s_%s_%s"):format(cache.resource, time, math.random(1, 1000))
        Wait(0)
    end
    local dictName = ('ox_lib_dui_dict_%s'):format(id)
    local txtName = ('ox_lib_dui_txt_%s'):format(id)
    local duiObject = CreateDui(data.url, data.width, data.height)
    local duiHandle = GetDuiHandle(duiObject)
    local runtimeTxd = CreateRuntimeTxd(dictName)
    local txdObject = CreateRuntimeTextureFromDuiHandle(runtimeTxd, txtName, duiHandle)
    self.id = id
    self.debug = data.debug or false
    self.url = data.url
    self.duiObject = duiObject
    self.duiHandle = duiHandle
    self.runtimeTxd = runtimeTxd
    self.txdObject = txdObject
    self.dictName = dictName
    self.txtName = txtName
    if self.debug then
        print(('Dui %s created'):format(id))
    end

    duis[id] = self
end

function lib.dui:remove()
    SetDuiUrl(self.duiObject, 'about:blank')
    DestroyDui(self.duiObject)
    duis[self.id] = nil

    if self.debug then
        print(('Dui %s removed'):format(self.id))
    end
end

---@param url string
function lib.dui:setUrl(url)
    self.url = url
    SetDuiUrl(self.duiObject, url)

    if self.debug then
        print(('Dui %s url set to %s'):format(self.id, url))
    end
end

---@param message table
function lib.dui:sendMessage(message)
    SendDuiMessage(self.duiObject, json.encode(message))

    if self.debug then
        print(('Dui %s message sent'):format(self.id))
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if cache.resource ~= resourceName then return end
    for _, dui in pairs(duis) do
        dui:remove()
    end
end)

return lib.dui
