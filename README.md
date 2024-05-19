# ox_lib Redesign by mur4i
A few changes redesign for overextened context menu, font changes, theme and colors.
Download the release if you want to use.

Added new features:
- Add new Context menu description
- Add new Background convar (ox.cfg)
```setr ox:menuBackground false #true forces background on every context menu from ox_lib```
- Add new Background color option

Example of use:
```lua
            lib.registerContext({
                id = 'test',
                title = 'title from menu',
                ---------------------------------- NEW OPTIONS BELOW
                description = 'description from menu', --new line description on menu
                background = true, --TOGGLE background for only this menu (you can change default to setr ox:menuBackground true)
                backgroundColor = '#ffffff', --change the background color
                [...]
            }) 
```

Changes only on: //resource/interface/client/context.lua
```lua
        data = {
            title = data.title,
            description = data.description, --murai
            background = data.background or GetConvarInt('ox:menuBackground', 0) == 1, --murai
            backgroundColor = data.backgroundColor, --murai
            canClose = data.canClose,
            menu = data.menu,
            options = data.options
        }
```
Preview:
![](/ox_lib-preview.png)


## Credits to overextended:
A FiveM library and resource implementing reusable modules, methods, and UI elements.

![](https://img.shields.io/github/downloads/overextended/ox_lib/total?logo=github)
![](https://img.shields.io/github/downloads/overextended/ox_lib/latest/total?logo=github)
![](https://img.shields.io/github/contributors/overextended/ox_lib?logo=github)
![](https://img.shields.io/github/v/release/overextended/ox_lib?logo=github) 

## 📚 Documentation

https://overextended.dev/ox_lib

## 💾 Download

https://github.com/overextended/ox_lib/releases/latest/download/ox_lib.zip

## npm Package

https://www.npmjs.com/package/@overextended/ox_lib

## Lua Language Server

- Install [Lua Language Server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) to ease development with annotations, type checking, diagnostics, and more.
- Install [cfxlua-vscode](https://marketplace.visualstudio.com/items?itemName=overextended.cfxlua-vscode) to add natives and cfxlua runtime declarations to LLS.
- You can load ox_lib into your global development environment by modifying workspace/user settings "Lua.workspace.library" with the resource path.
  - e.g. "c:/fxserver/resources/ox_lib"
