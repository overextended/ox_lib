## WIP Lua Library
FXServer provides its own system for including files, which we use to load this resource in the fxmanifest via
```lua
shared_script '@pe-lualib/init.lua'
```


Once loaded, any resource can use simple in-line declarations to load anything from the imports folder, i.e
```lua
local ServerCallback = import 'callbacks'
```

Refer to the [wiki](https://github.com/project-error/pe-lualib/wiki) for more information on usage.


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
