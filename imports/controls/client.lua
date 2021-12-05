--- Call on frame to disable all stored keys.
--- ```
--- DisableControlActions()
--- ```
local DisableControlActions = {}

---@param ... number
function DisableControlActions:Add(...)
	local keys = type(...) == 'table' and ... or {...}
	for i=1, #keys do
		local key = keys[i]
		if self[key] then
			self[key] += 1
		else
			self[key] = 1
		end
	end
end

---@param ... number
function DisableControlActions:Remove(...)
	local keys = type(...) == 'table' and ... or {...}
	for i=1, #keys do
		local key = keys[i]
		local exists = self[key]
		if exists and exists > 1 then
			self[key] -= 1
		else
			self[key] = nil
		end
	end
end

---@param ... number
function DisableControlActions:Clear(...)
	local keys = type(...) == 'table' and ... or {...}
	for i=1, #keys do
		self[keys[i]] = nil
	end
end

local Keys = {}
local DisableControlAction = DisableControlAction
local pairs = pairs

return setmetatable(DisableControlActions, {
	__index = Keys,
	__newindex = Keys,
	__call = function()
		for k in pairs(Keys) do
			DisableControlAction(0, k, true)
		end
	end
})