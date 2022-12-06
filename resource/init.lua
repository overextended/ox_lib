local debug_getinfo = debug.getinfo

lib = setmetatable({
    name = 'ox_lib',
    context = IsDuplicityVersion() and 'server' or 'client',
}, {
    __newindex = function(self, name, fn)
        rawset(self, name, fn)

        if debug_getinfo(2, 'S').short_src:find('@ox_lib/resource') then
            exports(name, fn)
        end
    end
})

cache = {
    resource = lib.name,
    game = GetGameName(),
}

if not LoadResourceFile(lib.name, 'web/build/index.html') then
    local err = '^1Unable to load UI. Build ox_lib or download the latest release.\n	^3https://github.com/overextended/ox_lib/releases/latest/download/ox_lib.zip^0'
    function lib.hasLoaded() return err end

    error(err)
end

function lib.hasLoaded() return true end
