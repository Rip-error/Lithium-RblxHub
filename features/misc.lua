local Misc = {}

local Config  = require(script.Parent.Parent.core.config)
local Helpers = require(script.Parent.Parent.core.helpers)
local Remote  = require(script.Parent.Parent.core.remote)

local Players         = Helpers.Players
local LocalPlayer     = Helpers.LocalPlayer
local RunService      = Helpers.RunService
local UserInputService= Helpers.UserInputService
local Workspace       = Helpers.Workspace
local Camera          = Helpers.Camera

local Tabs = _G.LITHIUM.Tabs
local Group = Tabs.Misc:AddRightGroupbox('Misc')

-- Anti Void
Group:AddToggle('AntiVoid', {
    Text = 'Anti Void',
    Default = true,
    Callback = function(v)
        Config.AntiVoid = v
        if v then Workspace.FallenPartsDestroyHeight = -math.huge
        else Workspace.FallenPartsDestroyHeight = -50 end
    end,
})

-- Anti Stomp
local function startAntiStomp()
    local function watchChar(chr)
        local hum = chr:WaitForChild("Humanoid", 5)
        local be = chr:WaitForChild("BodyEffects", 5)
        if not hum or not be then return end
        local ko = be:WaitForChild("K.O", 5)
        if not ko then return end
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not Config.AntiStomp then conn:Disconnect() return end
            if ko.Value and hum.Health > 0 then
                local tool = chr:FindFirstChildOfClass("Tool")
                if tool then tool.Parent = LocalPlayer.Backpack end
                for _, v in ipairs(chr:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then v:Destroy() end
                end
                for _, v in ipairs(chr:GetChildren()) do
                    if v:IsA("Accessory") and v:FindFirstChild("Handle") then v.Handle:Destroy() end
                end
                hum.Health = 0
            end
        end)
    end
    if LocalPlayer.Character then watchChar(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(function(c)
        if Config.AntiStomp then watchChar(c) end
    end)
end

Group:AddToggle('AntiStomp', {
    Text = 'Anti Stomp',
    Default = false,
    Callback = function(v)
        Config.AntiStomp = v
        if v then startAntiStomp() end
    end,
})

-- Anti Bag
local antiBagConn
Group:AddToggle('AntiBag', {
    Text = 'Anti Bag',
    Default = false,
    Callback = function(v)
        Config.AntiBag = v
        if v then
            if antiBagConn then antiBagConn:Disconnect() end
            antiBagConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Christmas_Sock") then
                    char.Christmas_Sock:Destroy()
                end
            end)
        else
            if antiBagConn then antiBagConn:Disconnect() antiBagConn = nil end
        end
    end,
})

-- Anti Grab
local antiGrabConn
Group:AddToggle('AntiGrab', {
    Text = 'Anti Grab',
    Default = false,
    Callback = function(v)
        Config.AntiGrab = v
        if v then
            if antiGrabConn then antiGrabConn:Disconnect() end
            antiGrabConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                local gc = char:FindFirstChild("GRABBING_CONSTRAINT")
                if gc then
                    gc:Destroy()
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Sit = true end
                end
            end)
        else
            if antiGrabConn then antiGrabConn:Disconnect() antiGrabConn = nil end
        end
    end,
})

-- Auto Reload
RunService.Heartbeat:Connect(function()
    if not Config.AutoReload then return end
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Ammo") and tool.Ammo.Value <= 0 then
        if Remote.MainEvent then Remote.MainEvent:FireServer("Reload", tool) end
    end
end)

Group:AddToggle('AutoReloadToggle', {
    Text = 'Auto Reload',
    Default = false,
    Callback = function(v) Config.AutoReload = v end,
})

-- God Block (auto-block on armed, off unarmed)
local blockConns = {}
local function startAutoBlock()
    table.insert(blockConns, RunService.Stepped:Connect(function()
        if not Config.GodBlock then return end
        local char = LocalPlayer.Character
        if not char then return end
        local be = char:FindFirstChild("BodyEffects")
        if be and be:FindFirstChild("Block") then be.Block:Destroy() end
        local tool = char:FindFirstChildWhichIsA("Tool")
        if tool and tool:FindFirstChild("Ammo") then
            Remote.MainEvent:FireServer("Block", false)
        else
            Remote.MainEvent:FireServer("Block", true)
            task.wait()
            Remote.MainEvent:FireServer("Block", false)
        end
    end))
end
local function stopAutoBlock()
    for _, c in ipairs(blockConns) do c:Disconnect() end
    blockConns = {}
end
Group:AddToggle('AutoBlock', {
    Text = 'God Block',
    Default = false,
    Callback = function(v)
        Config.GodBlock = v
        if v then startAutoBlock() else stopAutoBlock() end
    end,
})

-- Cash Aura
local cashAuraCfg = { Enabled = false, Range = 17, Cooldown = 0.2 }
local function getCash()
    local out = {}
    local drop = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Drop")
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not drop or not hrp then return out end
    for _, v in ipairs(drop:GetChildren()) do
        if v.Name == "MoneyDrop" then
            local pos = v:GetAttribute("OriginalPos") or v.Position
            if (pos - hrp.Position).Magnitude <= cashAuraCfg.Range then
                table.insert(out, v)
            end
        end
    end
    return out
end
local function cashAuraLoop()
    while cashAuraCfg.Enabled do
        for _, money in ipairs(getCash()) do
            local cd = money:FindFirstChildOfClass("ClickDetector")
            if cd then fireclickdetector(cd) end
        end
        task.wait(cashAuraCfg.Cooldown)
    end
end
Group:AddToggle('CashAura', {
    Text = 'Cash Aura',
    Default = false,
    Callback = function(v)
        cashAuraCfg.Enabled = v
        if v then task.spawn(cashAuraLoop) end
    end,
})
Group:AddSlider('CashAuraRange', {
    Text = 'Cash Aura Range',
    Default = 17, Min = 10, Max = 50, Rounding = 1,
    Callback = function(v) cashAuraCfg.Range = v end,
})
Group:AddSlider('CashAuraCD', {
    Text = 'Cash Aura Cooldown',
    Default = 0.2, Min = 0.1, Max = 1, Rounding = 2,
    Callback = function(v) cashAuraCfg.Cooldown = v end,
})

-- RPG / Grenade detection
local threatConn
local function startThreatDetection()
    if threatConn then return end
    threatConn = RunService.PostSimulation:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        local rpg = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Model") and Workspace.Ignored.Model:FindFirstChild("Launcher")
        local grenade = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Handle")
        local threat = (Config.AntiRPGDesync and rpg)
            or (Config.GrenadeDetection and grenade and (grenade.Position - hrp.Position).Magnitude < 16)
        if threat then
            local off = Vector3.new(math.random(-100,100), math.random(50,150), math.random(-100,100))
            hum.CameraOffset = -off
            local old = hrp.CFrame
            hrp.CFrame = CFrame.new(hrp.Position + off)
            task.wait()
            hrp.CFrame = old
        end
    end)
end
Group:AddToggle('RPGDetect', {
    Text = 'RPG Detection',
    Default = false,
    Callback = function(v)
        Config.AntiRPGDesync = v
        if v or Config.GrenadeDetection then startThreatDetection() end
    end,
})
Group:AddToggle('GrenadeDetect', {
    Text = 'Grenade Detection',
    Default = false,
    Callback = function(v)
        Config.GrenadeDetection = v
        if v or Config.AntiRPGDesync then startThreatDetection() end
    end,
})

-- Chat Spy
local TextChatService = game:GetService("TextChatService")
local chatWindow = TextChatService:FindFirstChild("ChatWindowConfiguration")
Group:AddToggle('ChatSpy', {
    Text = 'Chat Spy',
    Default = true,
    Callback = function(v)
        Config.ChatSpy = v
        if chatWindow then chatWindow.Enabled = v end
    end,
})

-- Infinite Zoom
local maxZoom = LocalPlayer.CameraMaxZoomDistance
Group:AddToggle('InfZoom', {
    Text = 'Infinite Zoom',
    Default = false,
    Callback = function(v)
        Config.InfiniteZoom = v
        if v then LocalPlayer.CameraMaxZoomDistance = math.huge
        else LocalPlayer.CameraMaxZoomDistance = maxZoom end
    end,
})

-- Force Reset
Group:AddButton('Force Reset', function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end)

-- No Jump Cooldown
RunService.RenderStepped:Connect(function()
    if not Config.NoJumpCooldown then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = not hum.UseJumpPower end
end)
Group:AddToggle('NoJumpCooldown', {
    Text = 'No Jump Cooldown',
    Default = false,
    Callback = function(v) Config.NoJumpCooldown = v end,
})

-- Force Admin Detection
local MOD_IDS = {
    163721789, 15427717, 201454243, 822999, 63794379, 17260230, 28357488, 93101606,
    8195210, 89473551, 16917269, 85989579, 1553950697, 476537893, 155627580,
    31163456, 7200829, 25717070, 16138978, 60660789, 1161411094, 9125623,
    11319153, 34758833, 194109750, 35616559, 1257271138, 28885841, 23558830,
    4255947062, 29242182, 2395613299, 3314981799, 3390225662, 2459178,
    2846299656, 2967502742, 7001683347, 7312775547, 328566086, 170526279,
    99356639, 352087139, 6074834798, 2212830051, 3944434729, 5136267958,
    84570351, 542488819, 1830168970, 3950637598, 1962396833,
}
local GROUP_IDS = {10604500, 17215700}

local antiModEnabled = false
local antiModMethod  = "Notify"
local groupCheckOn   = false
local modFriendsOn   = false

Group:AddToggle('AntiMod', {
    Text = 'Anti Mod Detection',
    Default = false,
    Callback = function(v)
        antiModEnabled = v
        if v then
            task.spawn(function()
                while antiModEnabled do
                    task.wait(1.5)
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player == LocalPlayer then continue end
                        if table.find(MOD_IDS, player.UserId) then
                            local msg = "MOD DETECTED: " .. player.DisplayName .. " (@" .. player.Name .. ")"
                            if antiModMethod == "Kick" then
                                LocalPlayer:Kick(msg)
                            else
                                Helpers.notify("Lithium", msg, 5)
                            end
                        end
                        if groupCheckOn then
                            for _, gid in ipairs(GROUP_IDS) do
                                local ok, inGroup = pcall(player.IsInGroup, player, gid)
                                if ok and inGroup then
                                    local role = "Unknown"
                                    pcall(function() role = player:GetRoleInGroup(gid) end)
                                    local msg = "[" .. role .. "] " .. player.DisplayName
                                    if antiModMethod == "Kick" then
                                        LocalPlayer:Kick(msg)
                                    else
                                        Helpers.notify("Lithium", msg, 5)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end,
})
Group:AddDropdown('AntiModMethod', {
    Values = {"Notify", "Kick"},
    Default = "Notify",
    Multi = false,
    Text = 'Anti Mod Method',
    Callback = function(v) antiModMethod = v end,
})
Group:AddToggle('GroupCheck', {
    Text = 'Staff Group Check',
    Default = false,
    Callback = function(v) groupCheckOn = v end,
})
Group:AddToggle('CheckModFriends', {
    Text = 'Check Mod Friends',
    Default = false,
    Callback = function(v)
        modFriendsOn = v
        if v then
            task.spawn(function()
                while modFriendsOn do
                    task.wait(8)
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player == LocalPlayer then continue end
                        pcall(function()
                            local friends = player:GetFriendsAsync()
                            for _, f in ipairs(friends:GetCurrentPage()) do
                                if table.find(MOD_IDS, f.Id) then
                                    Helpers.notify("Lithium", player.DisplayName .. " is friends with a Moderator", 6)
                                    break
                                end
                            end
                        end)
                    end
                end
            end)
        end
    end,
})

-- Unjail
Group:AddButton('Unjail (125$)', function()
    local currency = LocalPlayer:FindFirstChild("DataFolder") and LocalPlayer.DataFolder:FindFirstChild("Currency")
    if not currency or currency.Value < 125 then
        Helpers.notify("Lithium", "Not enough cash", 5)
        return
    end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(-270.94, 20.327, -242.38)
    task.wait(0.5)
    local keyShop = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Shop") and Workspace.Ignored.Shop:FindFirstChild("[Key] - $125")
    if keyShop and keyShop:FindFirstChild("ClickDetector") then
        fireclickdetector(keyShop.ClickDetector)
        task.wait(0.2)
        fireclickdetector(keyClick)
    end
    repeat task.wait() until LocalPlayer.Backpack:FindFirstChild("[Key]") or LocalPlayer.Character:FindFirstChild("[Key]")
    local key = LocalPlayer.Backpack:FindFirstChild("[Key]") or LocalPlayer.Character:FindFirstChild("[Key]")
    if key then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(key) end
        task.wait(0.3)
        hrp.CFrame = CFrame.new(-485.668, 23.631, -285.169)
        task.wait(0.5)
        key:Activate()
        Helpers.notify("Lithium", "Unjailed", 5)
    end
end)

-- Redeem Codes
Group:AddButton('Redeem All Codes', function()
    local codes = {"HAPPYHOLIDAYS25", "XMAS2025"}
    if not Remote.MainEvent then return end
    for _, code in ipairs(codes) do
        Remote.MainEvent:FireServer("EnterPromoCode", code)
        Helpers.notify("Lithium", "Redeeming: " .. code, 4)
        task.wait(4.2)
    end
    Helpers.notify("Lithium", "All codes redeemed", 6)
end)

return Misc