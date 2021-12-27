-- Creates exports from values assigned to lib
-- Hacky workaround for Lua Language Server support
--- Alias for `exports['pe-lualib']`

lib = setmetatable({}, {
	__newindex = function(_, name, fn)
		exports(name, fn)
	end
})