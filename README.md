## WIP Lua Library
### How to utilise in another resource

- fxmanifest.lua
```lua
fx_version 'cerulean'
game 'gta5'

author 'You'
version '1.0.0'
lua54 'yes'
use_fxv2_oal 'yes'

shared_script '@library/init.lua'

files {
    'client.lua',
    'shared.lua',
}
```

- client.lua
```lua
local ServerCallback = import 'callbacks'

ServerCallback.Async(targetresource, 'eventname', 100, function(result)
    print(result)
end, 'hello there')
```

- server.lua
```lua
local ServerCallback = import 'callbacks'

ServerCallback.Register('eventname', function(source, cb, data)
    cb(data..'. general kenobi')
end)
```
