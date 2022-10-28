lib = setmetatable({
	name = 'ox_lib',
	context = IsDuplicityVersion() and 'server' or 'client',
}, {
	__newindex = function(self, name, fn)
		exports(name, fn)
		rawset(self, name, fn)
	end
})

cache = {
	resource = lib.name
}

if not LoadResourceFile(lib.name, 'web/build/index.html') then
    local err = '^1Unable to load UI. Build ox_lib or download the latest release.\n	^3https://github.com/overextended/ox_lib/releases/latest/download/ox_lib.zip^0'
    function lib.hasLoaded() return err end
	error(err)
end

function lib.hasLoaded() return true end
