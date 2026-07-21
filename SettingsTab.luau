return function(Window)
	local function CloneReference(Object)
		if Abysall and Abysall.Environment.cloneref then
			return Abysall.Environment.cloneref(Object)
		else
			return Object
		end
	end
	
	local Services = setmetatable({}, {
		__index = function(self, Name)
			return CloneReference(game:GetService(Name))
		end
	})

	local Library = Abysall.Interface.Library
	local SaveManager = Abysall.Interface.SaveManager
	local ThemeManager = Abysall.Interface.ThemeManager
	
	local Toggles = Library.Toggles
	local Options = Library.Options
	
	local SettingsTab = Window:AddTab("Settings", "settings")
	local MenuGroup = SettingsTab:AddLeftGroupbox("Menu")
	
	MenuGroup:AddToggle("KeybindMenuOpen", {
		Default = Library.KeybindFrame.Visible,
		Text = "Open Keybind Menu",
		Callback = function(value)
			Library.KeybindFrame.Visible = value
		end,
	})
	MenuGroup:AddToggle("ShowCustomCursor", {
		Text = "Custom Cursor",
		Default = false,
		Callback = function(Value)
			Library.ShowCustomCursor = Value
		end,
	})

	MenuGroup:AddDropdown("UILibrary", {
		Text = "UI Style",
		Values = {
			"Obsidian",
			"Linoria"
		},
		Default = (Abysall.UILibrary == "Linoria" and 2 or 1),
		Callback = function(Value)
			if Abysall.Environment.writefile and Abysall.Environment.readfile then
				if not Abysall.Environment.isfile("HVHUB/UserData.json") then
					local Data = {
						TotalExecutions = 0,
						UILibrary = "Obsidian"
					}
					Abysall.Environment.writefile("HVHUB/UserData.json", Services.HttpService:JSONEncode(Data))
				end

				local UserData = Abysall.Environment.readfile("HVHUB/UserData.json")
				local Decoded = Services.HttpService:JSONDecode(UserData)
				Decoded.UILibrary = Value

				if not Decoded.UILibrary then
					Decoded.UILibrary = "Obsidian"
				end

				Abysall.TotalExecutions = Decoded.TotalExecutions
				Abysall.UILibrary = Decoded.UILibrary

				Abysall.Environment.writefile("HVHUB/UserData.json", Services.HttpService:JSONEncode(Decoded))
			end
		end
	})
	
	MenuGroup:AddDropdown("DPIDropdown", {
		Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
		Default = "100%",
	
		Text = "DPI Scale",
	
		Callback = function(Value)
			Value = Value:gsub("%%", "")
			local DPI = tonumber(Value)
	
			Library:SetDPIScale(DPI)
		end,
	})
	MenuGroup:AddDivider()
	MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
	
	MenuGroup:AddButton("Unload", function()
		Library:Unload()
	end)

	Library.ToggleKeybind = Options.MenuKeybind

	if typeof(loaders) == "function" and getgenv().Abysall then
		getgenv().Abysall.loaders = loaders()
	end

	local function UpdateTeleportQueue(IsEnabled)
		if not IsEnabled then return end
		
		local QueueTeleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
		if QueueTeleport then
			QueueTeleport([==[
				repeat task.wait() until game:IsLoaded()
				task.wait(1.5)
				
				if getgenv().Abysall and typeof(getgenv().Abysall.loaders) == "function" then
					getgenv().Abysall.loaders()
				elseif typeof(loaders) == "function" then
					loaders()
				else
					warn("[HVHUB Error]")
				end
			]==])
		end
	end

	local Player = Services.Players.LocalPlayer
	Player.OnTeleport:Connect(function(State)
		if State == Enum.TeleportState.Started and Toggles.AutoReloadHubToggle and Toggles.AutoReloadHubToggle.Value then
			UpdateTeleportQueue(true)
		end
	end)

	MenuGroup:AddToggle('Executeonteleporttoggle', {
		Text = 'Execute on teleport',
		Default = false,
		Tooltip = 'Executing script after teleport',
		Callback = function(Value)
			UpdateTeleportQueue(Value)
		end
	})

	ThemeManager:SetLibrary(Library)
	SaveManager:SetLibrary(Library)
	SaveManager:IgnoreThemeSettings()
	SaveManager:SetIgnoreIndexes({"UILibrary"})
	ThemeManager:SetFolder("HVHUB")
	SaveManager:SetFolder("HVHUB/" .. Abysall.SavePath)
	SaveManager:BuildConfigSection(SettingsTab)
	ThemeManager:ApplyToTab(SettingsTab)
	SaveManager:LoadAutoloadConfig()
end
