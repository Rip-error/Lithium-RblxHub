local Group = Tabs.Settings:AddLeftGroupbox('Menu')

Group:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu", Callback = function(v) Library.KeybindFrame.Visible = v end })
Group:AddDropdown("NotificationSide", { Values = {"Left","Right"}, Default = "Right", Text = "Notification Side", Callback = function(v) Library:SetNotifySide(v) end })
Group:AddDropdown("DPIDropdown", { Values = {"50%","75%","100%","125%","150%","175%","200%"}, Default = "100%", Text = "DPI Scale", Callback = function(v) v = v:gsub("%%","") Library:SetDPIScale(tonumber(v)) end })
Group:AddDivider()
Group:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Group:AddButton("Unload", function() Library:Unload() end)

local antiAfkConn
Group:AddToggle('AntiAFKToggle', {
    Text = 'Anti-AFK', Default = false,
    Callback = function(v)
        if v then
            local vu = game:GetService("VirtualUser")
            antiAfkConn = LocalPlayer.Idled:Connect(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        elseif antiAfkConn then
            antiAfkConn:Disconnect()
            antiAfkConn = nil
        end
    end,
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('lithium')
SaveManager:SetFolder('lithium/dahood')
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
Library.ToggleKeybind = Options.MenuKeybind

Library:OnUnload(function()
    if Config.Desync.Enabled and LocalPlayer.Character then
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        Config.Desync.Enabled = false
    end
    workspace.FallenPartsDestroyHeight = 0/0
    for _, c in pairs(_G.LITHIUM.Connections) do pcall(function() c:Disconnect() end) end
    Library.Unloaded = true
end)