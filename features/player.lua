local selectedPlayer
local spectateConn

local G = Tabs.Player:AddLeftGroupbox('Playerlist')
G:AddDropdown('PlayerSelect', { SpecialType = 'Player', ExcludeLocalPlayer = true, Multi = false, Text = 'Target', Searchable = true, Callback = function(v) selectedPlayer = v end })
G:AddButton('Set TargetAim', function()
    if selectedPlayer then Config.TargetAim.Target = selectedPlayer.Name notify("Lithium", "Target set: " .. selectedPlayer.Name, 3) end
end)
G:AddToggle('SpectateToggle', {
    Text = 'Spectate', Default = false,
    Callback = function(v)
        if v and selectedPlayer then
            if spectateConn then spectateConn:Disconnect() end
            spectateConn = RunService.Heartbeat:Connect(function()
                local hum = selectedPlayer.Character and selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then Camera.CameraSubject = hum
                elseif LocalPlayer.Character then Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end
            end)
        else
            if spectateConn then spectateConn:Disconnect() spectateConn = nil end
            if LocalPlayer.Character then Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end
        end
    end,
})
G:AddButton('Goto', function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
    end
end)

local function addPlaces(groupTitle, list)
    local g = Tabs.Player:AddLeftGroupbox(groupTitle)
    for name, cf in pairs(list) do
        g:AddButton(name, function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = cf end
        end)
    end
end

addPlaces('Main Places', {
    ["Bank"]                = CFrame.new(-442, 39, -284),
    ["Inside Bank"]         = CFrame.new(-443, 23, -284),
    ["Vault"]               = CFrame.new(-658, -30, -285),
    ["Mid Apartment Roof"]  = CFrame.new(-323, 80, -299),
    ["Revolver Shop"]       = CFrame.new(-634, 21, -132),
    ["LMG Shop"]            = CFrame.new(-626, 23, -295),
    ["Swimming Pool"]       = CFrame.new(-847, 21, -279),
    ["Broken Fire Station"] = CFrame.new(-1182, 28, -521),
    ["Downhill Gun Shop"]   = CFrame.new(-559, 8, -735),
    ["Uphill Gun Shop"]     = CFrame.new(481, 48, -602),
    ["Military Base"]       = CFrame.new(-40, 65, -926),
    ["Breaking Bad House"]  = CFrame.new(598, 28, -214),
    ["Church"]              = CFrame.new(205, 21, -124),
    ["Police Station"]      = CFrame.new(-264, 21, -93),
    ["School"]              = CFrame.new(-594, 21, 173),
})
addPlaces('Extra Places', {
    ["UFO"]           = CFrame.new(50, 138, -671),
    ["Casino"]        = CFrame.new(-866, 44, -156),
    ["Gas Station"]   = CFrame.new(537, 47, -248),
    ["Gym / Fitness"] = CFrame.new(-77, 22, -622),
})
addPlaces('Food Stores', {
    ["Food Store #1"] = CFrame.new(-336, 23, -298),
    ["Food Store #2"] = CFrame.new(299, 49, -617),
    ["Food Store #3"] = CFrame.new(-279, 22, -807),
    ["Food Store #4"] = CFrame.new(584, 51, -477),
    ["Food Store #5"] = CFrame.new(-995, 25, -157),
    ["Food Store #6"] = CFrame.new(-903, 22, -670),
})
addPlaces('Armor Locations', {
    ["Armor #1"] = CFrame.new(-605, 10, -788),
    ["Armor #2"] = CFrame.new(532, 50, -637),
    ["Armor #3"] = CFrame.new(-933, -28, 565),
    ["Armor #4"] = CFrame.new(409, 48, -50),
    ["Armor #5"] = CFrame.new(-257, 21, -78),
    ["Armor #6"] = CFrame.new(97, 23, -303),
})
addPlaces('Safe Zones', {
    ["Safe Zone #1"] = CFrame.new(-55, -58, 146),
    ["Safe Zone #2"] = CFrame.new(-124, -58, 130),
    ["Safe Zone #3"] = CFrame.new(-547, 173, -2),
})