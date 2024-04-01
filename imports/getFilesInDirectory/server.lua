---@param path string
---@param pattern string
---@return table string[]
---@return integer fileCount
function lib.getFilesInDirectory(path, pattern)
    local resource = cache.resource

    if path:find('^@') then
        resource = path:gsub('^@(.-)/.+', '%1')
        path = path:sub(#resource + 3)
    end

    local files = {}
    local fileCount = 0
    local windows = string.match(os.getenv('OS') or '', 'Windows')
    local command = ('%s%s%s'):format(
        windows and 'dir "' or 'ls "',
        (GetResourcePath(resource):gsub('//', '/') .. '/' .. path):gsub('\\', '/'),
        windows and '/" /b' or '/"'
    )

    local dir = io.popen(command)

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
