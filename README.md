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

shared_script '@pe-lualib/init.lua'

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

Target a registered ServerCallback in any resource by setting the first parameter to that resource name, then utilise whatever event name you desire.  
For my test, I utilised `test` and `testevent`, which registers an event with the name `__cb_test:testevent`.  

The third parameter sets a delay for how often the client can trigger the callback (to prevent spam in certain situations).  

There's also ServerCallback.Await which halts the thread and returns the values rather than using a callback (I haven't tested it since refactoring all this code, though).
