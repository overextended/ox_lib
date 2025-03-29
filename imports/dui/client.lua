--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class DuiProperties
---@field url string
---@field width number
---@field height number
---@field debug? boolean

---@class Dui : OxClass
---@field private private { id: string, debug: boolean }
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

local currentId = 0

---@param data DuiProperties
function lib.dui:constructor(data)
	local time = GetGameTimer()
	local id = ("%s_%s_%s"):format(cache.resource, time, currentId)
	currentId = currentId + 1
	local dictName = ('ox_lib_dui_dict_%s'):format(id)
	local txtName = ('ox_lib_dui_txt_%s'):format(id)
	local duiObject = CreateDui(data.url, data.width, data.height)
	local duiHandle = GetDuiHandle(duiObject)
	local runtimeTxd = CreateRuntimeTxd(dictName)
	local txdObject = CreateRuntimeTextureFromDuiHandle(runtimeTxd, txtName, duiHandle)
	self.private.id = id
	self.private.debug = data.debug or false
	self.url = data.url
	self.duiObject = duiObject
	self.duiHandle = duiHandle
	self.runtimeTxd = runtimeTxd
	self.txdObject = txdObject
	self.dictName = dictName
	self.txtName = txtName
	duis[id] = self

	if self.private.debug then
		print(('Dui %s created'):format(id))
	end
end

function lib.dui:remove()
	SetDuiUrl(self.duiObject, 'about:blank')
	DestroyDui(self.duiObject)
	duis[self.private.id] = nil

	if self.private.debug then
		print(('Dui %s removed'):format(self.private.id))
	end
end

---@param url string
function lib.dui:setUrl(url)
	self.url = url
	SetDuiUrl(self.duiObject, url)

	if self.private.debug then
		print(('Dui %s url set to %s'):format(self.private.id, url))
	end
end

---@param message table
function lib.dui:sendMessage(message)
	SendDuiMessage(self.duiObject, json.encode(message))

	if self.private.debug then
		print(('Dui %s message sent with data :'):format(self.private.id), json.encode(message, { indent = true }))
	end
end

AddEventHandler('onResourceStop', function(resourceName)
	if cache.resource ~= resourceName then return end

	for _, dui in pairs(duis) do
		dui:remove()
	end
end)

return lib.dui
