local TweenService = game:GetService("TweenService")
local prevHP = {}

local function playSound()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local s = Instance.new("Sound")
    s.Parent = hrp
    s.SoundId = Config.HitEffects.HitSoundID
    s.Volume = Config.HitEffects.HitSoundVolume
    s:Play()
    s.Ended:Connect(function() s:Destroy() end)
end

local function chams(plr)
    if not plr or not plr.Character then return end
    plr.Character.Archivable = true
    local c = plr.Character:Clone()
    c.Name = "LithiumChams"
    local keep = {Head=1,UpperTorso=1,LowerTorso=1,LeftUpperArm=1,LeftLowerArm=1,LeftHand=1,RightUpperArm=1,RightLowerArm=1,RightHand=1,LeftUpperLeg=1,LeftLowerLeg=1,LeftFoot=1,RightUpperLeg=1,RightLowerLeg=1,RightFoot=1}
    for _, p in ipairs(c:GetChildren()) do
        if p:IsA("BasePart") and not keep[p.Name] then p:Destroy() end
        if p:IsA("Accessory") or p:IsA("Tool") or p.Name == "face" or p:IsA("Shirt") or p:IsA("Pants") or p:IsA("Hat") then p:Destroy() end
    end
    if c:FindFirstChild("Humanoid") then c.Humanoid:Destroy() end
    for _, bp in ipairs(c:GetChildren()) do
        if bp:IsA("BasePart") then
            bp.CanCollide = false
            bp.Anchored = true
            bp.Transparency = Config.HitEffects.HitChams.Transparency
            bp.Color = Config.HitEffects.HitChams.Color
            bp.Material = Enum.Material[Config.HitEffects.HitChams.Material] or Enum.Material.Neon
        end
    end
    if c:FindFirstChild("Head") and c.Head:FindFirstChild("face") then c.Head.face:Destroy() end
    c.Parent = Workspace
    local info = TweenInfo.new(Config.HitEffects.HitChams.Lifetime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true)
    for _, bp in ipairs(c:GetChildren()) do
        if bp:IsA("BasePart") then TweenService:Create(bp, info, {Transparency = 1}):Play() end
    end
    task.delay(Config.HitEffects.HitChams.Lifetime, function()
        if c and c.Parent then c:Destroy() end
    end)
end

local function skeleton(plr)
    if not plr or not plr.Character then return end
    local bones = {
        {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
        {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
        {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
        {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
        {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    }
    local lines = {}
    for _, pair in ipairs(bones) do
        local a = plr.Character:FindFirstChild(pair[1])
        local b = plr.Character:FindFirstChild(pair[2])
        if a and b then
            local l = Instance.new("Part")
            l.Size = Vector3.new(0.02, 0.02, (a.Position - b.Position).Magnitude)
            l.CFrame = CFrame.new(a.Position, b.Position) * CFrame.new(0, 0, -l.Size.Z/2)
            l.Anchored = true
            l.CanCollide = false
            l.Transparency = Config.HitEffects.HitChams.Transparency
            l.Color = Config.HitEffects.HitSkeleton.Color
            l.Material = Enum.Material.Neon
            l.Parent = Workspace
            local info = TweenInfo.new(Config.HitEffects.HitChams.Lifetime / 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            TweenService:Create(l, info, {Transparency = 1}):Play()
            table.insert(lines, l)
        end
    end
    task.delay(Config.HitEffects.HitChams.Lifetime, function()
        for _, l in ipairs(lines) do if l and l.Parent then l:Destroy() end end
    end)
end

RunService.Heartbeat:Connect(function()
    if not Config.TargetAim.Enabled or Config.TargetAim.Target == "None" then return end
    local t = Players:FindFirstChild(Config.TargetAim.Target)
    if not t or not t.Character then return end
    local hum = t.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local cur = math.round(hum.Health)
    local prev = prevHP[t.Name]
    if prev and cur < prev then
        if Config.HitEffects.HitSounds then playSound() end
        if Config.HitEffects.HitNotifications then notify("Lithium", t.Name .. " hit - " .. cur .. " hp", Config.HitEffects.HitNotificationsTime) end
        if Config.HitEffects.HitChams.Enabled then chams(t) end
        if Config.HitEffects.HitSkeleton.Enabled then skeleton(t) end
    end
    prevHP[t.Name] = cur
end)

local G = Tabs.Main:AddLeftGroupbox('Hit Effects')
G:AddToggle('HitChamsEnabled', { Text = 'Hit Chams', Default = false, Callback = function(v) Config.HitEffects.HitChams.Enabled = v end }):AddColorPicker('HitChamsColor', { Default = Color3.fromRGB(255,255,255), Title = 'Chams Color', Callback = function(c) Config.HitEffects.HitChams.Color = c end })
G:AddDropdown('HitChamsMaterial', { Values = {'Neon','ForceField'}, Default = 1, Multi = false, Text = 'Material', Callback = function(v) Config.HitEffects.HitChams.Material = v end })
G:AddSlider('HitChamsLifetime', { Text = 'Lifetime', Min = 1, Max = 10, Default = 3, Rounding = 1, Callback = function(v) Config.HitEffects.HitChams.Lifetime = v end })
G:AddSlider('HitChamsTransparency', { Text = 'Transparency', Min = 0, Max = 1, Default = 0.7, Rounding = 2, Callback = function(v) Config.HitEffects.HitChams.Transparency = v end })
G:AddToggle('HitSkeleton', { Text = 'Hit Skeleton', Default = false, Callback = function(v) Config.HitEffects.HitSkeleton.Enabled = v end }):AddColorPicker('HitSkeletonColor', { Default = Color3.fromRGB(255,255,255), Title = 'Skeleton Color', Callback = function(c) Config.HitEffects.HitSkeleton.Color = c end })
G:AddToggle('HitSounds', { Text = 'Hit Sounds', Default = false, Callback = function(v) Config.HitEffects.HitSounds = v end })
G:AddSlider('HitSoundVolume', { Text = 'Volume', Min = 1, Max = 10, Default = 5, Rounding = 0, Callback = function(v) Config.HitEffects.HitSoundVolume = v end })
G:AddToggle('HitNotifications', { Text = 'Hit Notifications', Default = false, Callback = function(v) Config.HitEffects.HitNotifications = v end })
G:AddSlider('NotifyTime', { Text = 'Notify Time', Min = 1, Max = 10, Default = 3, Rounding = 0, Callback = function(v) Config.HitEffects.HitNotificationsTime = v end })