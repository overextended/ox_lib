-- Creates exports from values assigned to lib.
-- Hacky workaround for Lua Language Server support.

lib = setmetatable({}, {
	__newindex = function(self, name, fn)
		print('created '..name)
		exports(name, fn)
	end
})