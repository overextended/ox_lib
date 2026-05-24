---@class OxLibConfig
Config = {}

---The default locale used by ox_lib.
---Must match a JSON file in the `locales/` directory (without the `.json` extension).
---Examples: 'en', 'ka', 'tr', 'ru'
---
---This value is used when `ox:locale` is not set in server.cfg.
---Players can still override the locale in-game when `ox:userLocales` is enabled.
Config.Locale = 'en'
