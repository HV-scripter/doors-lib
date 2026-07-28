local BaseUrl = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local HVUrl = "https://raw.githubusercontent.com/HV-scripter/doors-lib/refs/heads/main/"

local Interface = {
  Library = loadstring(game:HttpGet(BaseUrl .. "Library.lua"))(),
  SaveManager = loadstring(game:HttpGet(BaseUrl .. "addons/SaveManager.lua"))(),
  ThemeManager = loadstring(game:HttpGet(BaseUrl .. "addons/ThemeManager.lua"))(),

  ApplySettingsTab = loadstring(game:HttpGet(HVUrl .. "SettingsTab.luau"))()
}

return Interface
