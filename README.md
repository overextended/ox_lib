## WIP Lua Library
FXServer provides its own system for including files, which we use to load this resource in the fxmanifest via
```lua
shared_script '@pe-lualib/init.lua'
```


Once loaded, any resource can use simple in-line declarations to load anything from the imports folder, i.e
```lua
local ServerCallback = import 'callbacks'
```


If you don't want to use this resource, but want to reuse code you are permitted to do so under the [license terms](https://www.gnu.org/licenses/gpl-3.0.html).  
Any resources distributed with this code is subject to the same license restrictions and must be made available under the same license ([more below](#license)).

#### Currently implemented
- [x] Server callbacks
- [x] Table utilities
- [x] Streaming exports
- [x] SetInterval

#### To do
- Think of more features
- Improvements to import function?
- Improve table utilities (matches only work if the order is the same)
- Transfer non-essential code from ox inventory
- Entity iterators
- Exports for non-runtime critical functions

#### Native wrappers
Likely to be handled as exports rather than imports, handling things such as entity creation, blips, markers, etc.  
Anything that is capable of OneSync RPC's is prioritised over direct client functions.  

#### Compatibility wrappers
Setup imports for ESX and QBCore compatibility with certain tables, functions, and events; this should only be for important framework features, i.e
- PlayerData / xPlayer / QBPlayer
- GetPlayers / GetExtendedPlayers / GetQBPlayers

<br>

## Usage
Resources are required to utilise Lua 5.4 to ensure compatibility.  
Any scripts must be loaded _after_ initialising the shared import.
```lua
lua54 'yes'
shared_script '@pe-lualib/init.lua'
```

### ServerCallbacks
- server.lua
```lua
local ServerCallback = import 'callbacks'

-- Registers a server event with the name __cb_resourceName:eventName
ServerCallback.Register('eventName', function(source, cb, data)
    cb(data, 'general kenobi')
end)
```
- client.lua
```lua
local ServerCallback = import 'callbacks'

-- Trigger the server event and receive a callback function
ServerCallback.Async('resourceName', 'eventName', 100, function(a, b)
    print(a, b) -- 'hello there', 'general kenobi'
end, 'hello there')

-- Trigger the server event and await a promise
CreateThread(function()
    local a, b = ServerCallback.Await('resourceName', 'eventName', 100, 'hello there')
    print(a, b) -- 'hello there', 'general kenobi'
end)
```


<br><h2>License</h2>
<table><tr><td>
pe-lualib  

Copyright (C) 2021	Linden <https://www.github.com/thelindat>


This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.


This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.


You should have received a copy of the GNU General Public License along with this program.  
If not, see <https://www.gnu.org/licenses/gpl-3.0.html>
</td></tr>
<tr><td>
<font align='center'>https://tldrlegal.com/license/gnu-general-public-license-v3-(gpl-3)</font>
</td></td></table>