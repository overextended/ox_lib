<div align='center'><h1><a href='https://overextended.github.io/docs/'>Documentation</a></h3></div>
<br>

## Lua Library for FiveM

FXServer provides its own system for including files, which we use to load this resource in the fxmanifest via

```lua
shared_script '@ox_lib/init.lua'
```

### server.cfg

```
add_ace resource.ox_lib command.add_ace allow
add_ace resource.ox_lib command.remove_ace allow
add_ace resource.ox_lib command.add_principal allow
add_ace resource.ox_lib command.remove_principal allow
```

## License
<a href='https://www.gnu.org/licenses/lgpl-3.0.en.html'>LGPL-3.0-or-later</a>
