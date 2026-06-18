--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@param path string
---@param pattern string
---@return table string[]
---@return integer fileCount
function lib.getFilesInDirectory(path, pattern)
    local resource = cache.resource

    -- io.readdir is NOT sandboxed to the resource directory, so reject directory traversal.
    if type(path) ~= 'string' or path:find('..', 1, true) then
        error("path must be a string and cannot contain '..' (directory traversal is not allowed)", 2)
    end

    if path:sub(1, 1) ~= '@' then
        path = ('%s/%s'):format(GetResourcePath(resource), path)
    end

    local files = {}
    local fileCount = 0
    local dir = io.readdir(path)

    if dir then
        for line in dir:lines() do
            if line:match(pattern) then
                fileCount += 1
                files[fileCount] = line
            end
        end

        dir:close()
    end

    return files, fileCount
end

return lib.getFilesInDirectory
