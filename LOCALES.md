# Locales

ox_lib ships with JSON locale files in the `locales/` directory. English (`en.json`) is always loaded as the base locale; the active locale is merged on top so missing keys fall back to English automatically.

## Setting the language

### Recommended: `config.lua`

Edit `config.lua` in the ox_lib resource root:

```lua
Config.Locale = 'ka'
```

Supported values are the locale file names without the `.json` extension, for example:

- `en` — English
- `ka` — Georgian (ქართული)
- `tr` — Turkish (Türkçe)
- `ru` — Russian (Русский)

Restart the resource or server after changing this value.

### Alternative: server convar

You can also set the locale from `server.cfg`:

```cfg
setr ox:locale ka
```

When both are configured, the `ox:locale` convar takes precedence. This preserves existing server setups that already use the convar.

### Per-player override (client)

When `ox:userLocales` is enabled (default), players can change their language from the `/ox_lib` settings menu. That choice is stored locally and overrides the server default for that player only.

## Fallback behavior

ox_lib resolves locale strings in this order:

1. Load `locales/en.json` as the base table.
2. Merge the active locale file on top (for example `locales/ka.json`).
3. If the active locale file does not exist, log a warning and use English only.
4. If a translation key is missing in the active locale, the English value is kept.
5. If a key does not exist in any locale, the key name is returned unchanged.

This applies to both Lua (`locale('key')`) and the NUI interface.

## Adding a new locale

1. Copy `locales/en.json` to `locales/<code>.json` (for example `locales/ka.json`).
2. Translate the string values. Keep the JSON keys identical to `en.json`.
3. Set the top-level `"language"` field to the display name shown in the settings menu.
4. Save the file as **UTF-8** (without BOM).

Example structure:

```json
{
  "language": "ქართული",
  "settings": "პარამეტრები",
  "ui": {
    "cancel": "გაუქმება"
  }
}
```

5. Set `Config.Locale = '<code>'` or `setr ox:locale <code>`.

Nested keys are flattened internally (`ui.cancel` → `"ui.cancel"`), so keep the same nesting as `en.json`.

## UTF-8 requirements

All locale files must be saved as UTF-8. This is required for languages that use multibyte characters, including:

- Georgian — `ქართული`, `გაუქმება`, `დადასტურება`
- Turkish — `Türkçe`, `İptal`, `Ş`, `ğ`, `ü`, `ö`, `ç`
- Russian — `Русский`, `Отменить`

Do not re-encode locale files as ANSI or Latin-1. ox_lib uses Lua 5.4 and `json.decode`, which handle UTF-8 strings correctly. Avoid manual byte-level string slicing on translated text.

## Using locales in other resources

Import the locale module from your resource `fxmanifest.lua`:

```lua
ox_lib 'locale'
```

Then call:

```lua
locale('your_key')
```

For resource-specific strings, add your own `locales/<code>.json` files and call `lib.locale()` during startup.

## API reference

| Function | Description |
| --- | --- |
| `Config.Locale` | Default locale code from `config.lua` |
| `lib.getLocaleKey()` | Returns the active locale code |
| `lib.setLocale(key)` | Client-only. Changes locale at runtime and updates NUI |
| `lib.loadLocaleData(key)` | Returns merged locale table (`en` + requested locale) |
| `lib.locale(key?)` | Loads and caches locale strings for Lua |
| `locale(key, ...)` | Returns a translated string, with optional `string.format` args |

Exports and callbacks are unchanged from previous ox_lib versions.
