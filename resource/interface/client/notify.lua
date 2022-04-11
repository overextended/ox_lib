--[[```lua
{
	id?: string
	title?: string
	description: string
	duration?: number
	position?: 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left'
	style?: table
	icon?: string
	iconColor?: string
}
```]]
---@param data table
function lib.notify(data)
	SendNUIMessage({
		action = 'customNotify',
		data = data
	})
end
