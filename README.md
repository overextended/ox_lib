<div align='center'><h1><a href='https://overextended.github.io/docs/'>Documentation</a></h3></div>
<br>

## ox_lib

Cfx provides functionality for loading external files in a resource through fxmanifest.

```lua
lua54 'yes'
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

## Lua Language Server

- Install [Lua Language Server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) to ease development with annotations, type checking, diagnostics, and more.
- Install [cfxlua-vscode](https://marketplace.visualstudio.com/items?itemName=overextended.cfxlua-vscode) to add natives and cfxlua runtime declarations to LLS.
- You can load ox_lib into your global development environment by modifying workspace/user settings "Lua.workspace.library" with the resource path.
  - e.g. "c:\\fxserver\\resources\\ox_lib"
