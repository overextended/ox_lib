local locales, localesN = lib.getFilesInDirectory('locales', '%.json')

for i = 1, localesN do
    local key = locales[i]
    local value = key:gsub('%.json', '')
    local label = (json.decode(LoadResourceFile(lib.name, ('locales/%s'):format(key)) or '') or '').language or value
    locales[i] = { label = label, value = value }
end

table.sort(locales, function(a, b)
    return a.label < b.label
end)

GlobalState['ox_lib:locales'] = locales

SetTimeout(2000, function()
    local stateBagStrictMode = GetConvarBool('sv_stateBagStrictMode', false)

    if stateBagStrictMode then return end

        print([[
^3━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  SECURITY WARNING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━^0
sv_stateBagStrictMode is currently ^1DISABLED.^0

State bags are used to replicate entity/player data between server and clients.
When strict mode is OFF, clients are able to replicate or influence state bag values.

Enabling strict mode improves security by rejecting replicated state bag modifications from clients.

^2Enable with:^0 setr sv_stateBagStrictMode true

^1Important:^0 Some scripts may break or stop syncing when strict mode is enabled.
If you experience issues, update resource logic to comply with strict replication rules.
^3━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━^0]])
end)