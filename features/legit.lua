local Legit = {}

local Config  = require(script.Parent.Parent.core.config)
local Helpers = require(script.Parent.Parent.core.helpers)
local Remote  = require(script.Parent.Parent.core.remote)

local Players          = Helpers.Players
local LocalPlayer      = Helpers.LocalPlayer
local RunService       = Helpers.RunService
local UserInputService = Helpers.UserInputService
local Camera           = Helpers.Camera
local Workspace        = Helpers.Workspace

local Tabs = _G.LITHIUM.Tabs
local LegitBox = Tabs.Main:AddRightTabbox()
local AimlockBox = LegitBox:AddTab('Aimlock')
local TriggerBox = LegitBox:AddTab('TriggerBot')

local VelocityTracker = {}

RunService.Heartbeat:Connect(function(dt)
    if dt > 0.5 then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            if not VelocityTracker[plr] then
                VelocityTracker[plr] = { PreviousPos = hrp.Position, PreviousTime = tick() }
            end
            local t = VelocityTracker[plr]
            t.Velocity = (hrp.Position - t.PreviousPos) / (tick() - t.PreviousTime)
            t.PreviousPos = hrp.Position
            t.PreviousTime = tick()
        end
    end
end)

Players.PlayerRemoving:Connect(function(p) VelocityTracker[p] = nil end)

local function updateAimlock()
    if not Config.Aimlock.Enabled then return end
    local target = Players:FindFirstChild(Config.TargetAim.Target)
    if not target or not target.Character then return end
    local part = target.Character:FindFirstChild(Config.Aimlock.HitPart)
    if not part then return end
    if not Helpers.isAlive(target) or not Helpers.isPlayerVisible(target) then return end

    local velocity = part.AssemblyLinearVelocity
    if Config.Aimlock.Resolver and VelocityTracker[target] then
        velocity = VelocityTracker[target].Velocity
    end

    local pos = part.Position + velocity * (Config.Aimlock.Prediction or 0)
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if Config.Aimlock.Offset and hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
        pos = pos + Vector3.new(0, Config.Aimlock.JumpOffset or 0, 0)
    end

    local goal = CFrame.new(Camera.CFrame.Position, pos)
    if Config.Aimlock.Smoothing then
        Camera.CFrame = Camera.CFrame:Lerp(goal, Config.Aimlock.SmoothingAmount)
    else
        Camera.CFrame = goal
    end
end

RunService.RenderStepped:Connect(updateAimlock)

AimlockBox:AddToggle('AimlockEnabled', {
    Text = 'Aimlock',
    Default = false,
    Callback = function(v) Config.Aimlock.Enabled = v end,
})
AimlockBox:AddDropdown('AimlockHitPart', {
    Values = {'Head', 'UpperTorso', 'HumanoidRootPart'},
    Default = 1,
    Multi = false,
    Text = 'Hit Part',
    Callback = function(v) Config.Aimlock.HitPart = v end,
})
AimlockBox:AddToggle('SmoothingEnabled', {
    Text = 'Smoothing',
    Default = false,
    Callback = function(v) Config.Aimlock.Smoothing = v end,
})
AimlockBox:AddSlider('SmoothingAmount', {
    Text = 'Smoothing Amount',
    Default = 0.1, Min = 0, Max = 1, Rounding = 2,
    Callback = function(v) Config.Aimlock.SmoothingAmount = v end,
})
AimlockBox:AddSlider('AimlockPrediction', {
    Text = 'Prediction',
    Default = 0.05, Min = 0, Max = 1, Rounding = 2,
    Callback = function(v) Config.Aimlock.Prediction = v end,
})
AimlockBox:AddSlider('AimlockJumpOffset', {
    Text = 'Jump Offset',
    Default = 0, Min = -10, Max = 10, Rounding = 1,
    Callback = function(v) Config.Aimlock.JumpOffset = v end,
})
AimlockBox:AddToggle('AimlockResolver', {
    Text = 'Resolver',
    Default = false,
    Callback = function(v) Config.Aimlock.Resolver = v end,
})

local function distToCursor(part)
    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return math.huge end
    return (Vector2.new(sp.X, sp.Y) - UserInputService:GetMouseLocation()).Magnitude
end

local function fireTrigger()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildWhichIsA("Tool")
    local ammo = tool and tool:FindFirstChild("Ammo")
    if tool and ammo then
        pcall(function() tool:Activate() end)
    else
        if UserInputService.TouchEnabled then
            local vim = game:GetService("VirtualInputManager")
            local pos = UserInputService:GetMouseLocation()
            vim:SendTouchEvent(0, Enum.UserInputState.Begin, pos)
            task.wait()
            vim:SendTouchEvent(0, Enum.UserInputState.End, pos)
        else
            if mouse1press then
                mouse1press()
                task.wait()
                mouse1release()
            elseif mouse1click then
                mouse1click()
            end
        end
    end
end

local function isValidTriggerTarget(plr)
    if plr == LocalPlayer or not plr.Character then return false end
    if not plr.Character:FindFirstChild("HumanoidRootPart") then return false end
    local hum = plr.Character:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if Config.Triggerbot.OnlyTarget then
        if not Config.TargetAim.Target or plr.Name ~= Config.TargetAim.Target then return false end
    end
    if Config.Triggerbot.CheckTeam and plr.Team == LocalPlayer.Team then return false end
    if Config.Triggerbot.CheckFriend and LocalPlayer:IsFriendsWith(plr.UserId) then return false end
    if Config.Triggerbot.CheckKO and Helpers.isKO(plr) then return false end
    if Config.Triggerbot.CheckGrab and Helpers.isGrabbed(plr) then return false end
    if Config.Triggerbot.CheckKnife and Helpers.isHoldingKnife() then return false end
    return true
end

local function getBestTriggerPart()
    local bestPart, bestDist = nil, Config.Triggerbot.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTriggerTarget(plr) and plr.Character then
            for _, partName in ipairs(Config.Triggerbot.SelectedHitParts) do
                local part = plr.Character:FindFirstChild(partName)
                if part and part:IsA("BasePart") then
                    local d = distToCursor(part)
                    if d < bestDist then
                        bestPart = part
                        bestDist = d
                    end
                end
            end
        end
    end
    return bestPart, bestDist
end

RunService.RenderStepped:Connect(function()
    if not Config.Triggerbot.Enabled then return end
    local part, dist = getBestTriggerPart()
    if not part or dist > Config.Triggerbot.FOV then return end
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin).Unit * 1000
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances = {LocalPlayer.Character}
    local result = Workspace:Raycast(origin, dir, rp)
    if not result then return end
    if result.Instance and result.Instance:IsDescendantOf(part.Parent) then
        task.delay(Config.Triggerbot.Delay, fireTrigger)
    end
end)

TriggerBox:AddToggle('TriggerbotEnabled', {
    Text = 'Enabled',
    Default = false,
    Callback = function(v) Config.Triggerbot.Enabled = v end,
}):AddKeyPicker('TriggerKey', {
    Default = 'none',
    Text = 'TriggerBot',
    Mode = 'Toggle',
    Callback = function(v) Config.Triggerbot.Enabled = v end,
})
TriggerBox:AddToggle('TriggerbotOnlyTarget', {
    Text = 'Only Target',
    Default = false,
    Callback = function(v) Config.Triggerbot.OnlyTarget = v end,
})
TriggerBox:AddSlider('TriggerbotFOV', {
    Text = 'Trigger FOV',
    Default = 20, Min = 1, Max = 200, Rounding = 1,
    Callback = function(v) Config.Triggerbot.FOV = v end,
})
TriggerBox:AddSlider('TriggerbotDelay', {
    Text = 'Trigger Delay',
    Default = 0, Min = 0, Max = 4, Rounding = 2,
    Callback = function(v) Config.Triggerbot.Delay = v end,
})
TriggerBox:AddDropdown('TriggerbotHitParts', {
    Text = 'Hit Parts',
    Values = {
        "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso",
        "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
        "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg",
        "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot",
    },
    Default = Config.Triggerbot.SelectedHitParts,
    Multi = true,
    Callback = function(sel) Config.Triggerbot.SelectedHitParts = sel end,
})
TriggerBox:AddDropdown('TriggerbotChecks', {
    Text = 'Trigger Checks',
    Values = {"KO", "Knife", "Grab", "Team", "Friend"},
    Default = {},
    Multi = true,
    Callback = function(sel)
        Config.Triggerbot.CheckKO     = table.find(sel, "KO")     ~= nil
        Config.Triggerbot.CheckKnife  = table.find(sel, "Knife")  ~= nil
        Config.Triggerbot.CheckGrab   = table.find(sel, "Grab")   ~= nil
        Config.Triggerbot.CheckTeam   = table.find(sel, "Team")   ~= nil
        Config.Triggerbot.CheckFriend = table.find(sel, "Friend") ~= nil
    end,
})

return Legit