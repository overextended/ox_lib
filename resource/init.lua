local debug_getinfo = debug.getinfo

function noop() end

-- Sandboxed builds log an error for every LoadResourceFile miss, so list each
-- module directory via io.readdir before probing files. Falls back to probing
-- when io.readdir is unavailable (listing == false).
local moduleFiles = {}

local function getModuleFiles(dir)
    local listing = moduleFiles[dir]

    if listing == nil then
        listing = false

        if type(io) == 'table' and io.readdir then
            local ok, handle = pcall(io.readdir, ('@ox_lib/%s'):format(dir))

            if ok and handle then
                listing = {}

                for entry in handle:lines() do
                    listing[entry] = true
                end

                pcall(handle.close, handle)
            end
        end

        moduleFiles[dir] = listing
    end

    return listing
end

local function loadResourceFileSafe(resource, dir, file)
    local listing = getModuleFiles(dir)

    if listing and not listing[file] then return nil end

    return LoadResourceFile(resource, ('%s/%s'):format(dir, file))
end

lib = setmetatable({
    name = 'ox_lib',
    context = IsDuplicityVersion() and 'server' or 'client',
}, {
    __newindex = function(self, key, fn)
        rawset(self, key, fn)

        if debug_getinfo(2, 'S').short_src:find('@ox_lib/resource') then
            exports(key, fn)
        end
    end,

    __index = function(self, key)
        local dir = ('imports/%s'):format(key)
        local chunk = loadResourceFileSafe(self.name, dir, ('%s.lua'):format(self.context))
        local shared = loadResourceFileSafe(self.name, dir, 'shared.lua')

        if shared then
            chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
        end

        if chunk then
            local fn, err = load(chunk, ('@@ox_lib/%s/%s.lua'):format(key, self.context))

            if not fn or err then
                return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
            end

            rawset(self, key, fn() or noop)

            return self[key]
        end
    end
})

cache = {
    resource = lib.name,
    game = GetGameName(),
}

if not LoadResourceFile(lib.name, 'web/build/index.html') then
    local err =
    '^1Unable to load UI. Build ox_lib or download the latest release.\n	^3https://github.com/overextended/ox_lib/releases/latest/download/ox_lib.zip^0'
    function lib.hasLoaded() return err end

    error(err)
end

function lib.hasLoaded() return true end

require = lib.require
