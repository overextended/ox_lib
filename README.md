## Lua Library for FiveM
FXServer provides its own system for including files, which we use to load this resource in the fxmanifest via
```lua
shared_script '@ox_lib/init.lua'
```


<div align='center'><h3><a href='https://overextended.github.io/docs/'>Documentation</a></h3></div>


Once loaded, any resource can call exports or load modules with the `lib` keyword, i.e.
```lua
lib.callbacks.Register(...)
```

Modules are loaded into the environment of the invoking resource, unlike exports which are called via function reference.


If you don't want to use this resource, but want to reuse code you are permitted to do so under the [license terms](https://www.gnu.org/licenses/gpl-3.0.html).  
Any resources distributed with this code is subject to the same license restrictions and must be made available under the same license ([more below](#license)).


<br><h2>License</h2>
<table><tr><td>
ox_lib

Copyright (C) 2021	Linden <https://www.github.com/thelindat>


This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.


This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.


You should have received a copy of the GNU General Public License along with this program.  
If not, see <https://www.gnu.org/licenses/gpl-3.0.html>
</td></tr>
<tr><td>
<font align='center'>https://tldrlegal.com/license/gnu-general-public-license-v3-(gpl-3)</font>
</td></td></table>
