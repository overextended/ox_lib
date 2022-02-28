-- Creates exports from values assigned to lib
-- Hacky workaround for Lua Language Server support
--- Alias for `exports.ox_lib`

lib = setmetatable({}, {
	__newindex = function(self, name, fn)
		exports(name, fn)
		rawset(self, name, fn)
	end
})
