## WIP Lua Library
The idea of this resource is to create a set of reusable functions for importing into other resources. Though FiveM has its own system for importing files (which is used to load init), this simplifies declarations and allows you to keep everything as `locals` rather than polluting the global namespace.  

Everyone is free to utilise either the library or code from it so long as [the license is respected and adhered to](https://tldrlegal.com/license/gnu-general-public-license-v3-(gpl-3)).

- [x] Server Callbacks
- [ ] Table utilities
- [ ] OxMySQL library
- [ ] Native wrappers (animations, spawning, etc.)
- [ ] Iterators
- todo: think of more features

### How to utilise ServerCallbacks

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
    print(result) -- 'hello there. general kenobi'
end, 'hello there')

CreateThread(function()
    local a, b, c = ServerCallback.Await('test', 'testevent', 100, 'hello there')
    print(a, b, c) -- 'hello there. general kenobi', 'two', nil
end)
```

- server.lua
```lua
local ServerCallback = import 'callbacks'

ServerCallback.Register('eventname', function(source, cb, data)
    cb(data..'. general kenobi', 'two')
end)
```

##### Target a registered ServerCallback in any resource by setting the first parameter to that resource name, then utilise whatever event name you desire. For my test, I utilised `test` and `testevent`, which registers an event with the name `__cb_test:testevent`. The third parameter sets a delay for how often the client can trigger the callback (to prevent spam in certain situations).  
