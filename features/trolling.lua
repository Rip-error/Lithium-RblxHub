local Trolling = {}

local Config  = require(script.Parent.Parent.core.config)
local Helpers = require(script.Parent.Parent.core.helpers)
local Remote  = require(script.Parent.Parent.core.remote)

local Players          = Helpers.Players
local LocalPlayer      = Helpers.LocalPlayer
local RunService       = Helpers.RunService
local UserInputService = Helpers.UserInputService
local Workspace        = Helpers.Workspace
local TweenService     = game:GetService("TweenService")

local Tabs = _G.LITHIUM.Tabs
local Group = Tabs.Misc:AddLeftGroupbox('Trolling')

local grabbed = false
local up = false
local lastStompTime = 0
local STOMP_COOLDOWN = 2
local STOMP_EFFECT = "Spirit"

local function deleteByName(parent, names)
    if not parent then return end
    for _, d in ipairs(parent:GetDescendants()) do
        if table.find(names, d.Name) then d:Destroy() end
    end
end

local function initGrab()
    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("BodyEffects")
    LocalPlayer.Character.BodyEffects.Grabbed:GetPropertyChangedSignal("Value"):Connect(function()
        local grabbedChar = LocalPlayer.Character.BodyEffects.Grabbed.Value
        if grabbedChar then
            deleteByName(grabbedChar, {"BodyVelocity", "BodyGyro", "BodyPosition"})
            if not grabbed then return end

            local upperTorso = grabbedChar:FindFirstChild("UpperTorso")
            if not upperTorso then return end
            repeat task.wait() until grabbedChar:FindFirstChild("GRABBING_CONSTRAINT")
            local gc = grabbedChar:FindFirstChild("GRABBING_CONSTRAINT")
            if gc and gc:FindFirstChild("H") then gc.H.Length = 9e9 end

            local bodyPos = Instance.new("BodyPosition")
            bodyPos.D = 200
            bodyPos.MaxForce = Vector3.new(10000, 10000, 10000)
            bodyPos.Parent = upperTorso

            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.D = 100
            bodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
            bodyGyro.Parent = upperTorso

            RunService.Heartbeat:Connect(function()
                if not grabbed then return end
                local char = LocalPlayer.Character
                if not char then return end
                local rh = char:FindFirstChild("RightHand")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not rh or not hrp or not upperTorso.Parent then return end
                bodyPos.Position = rh.Position - Vector3.new(0, 1, 0)
                bodyGyro.CFrame = CFrame.new(upperTorso.Position, hrp.Position)
            end)
        end
    end)
end

local GrabTool = Instance.new("Tool")
GrabTool.Name = "Activate"
GrabTool.RequiresHandle = false
GrabTool.ToolTip = "Grab"
GrabTool.Activated:Connect(function()
    if not Remote.MainEvent then return end
    Remote.MainEvent:FireServer("Grabbing", true)
end)

Group:AddToggle('GrabEnabled', {
    Text = 'Grab',
    Default = false,
    Callback = function(v)
        grabbed = v
        if v then
            GrabTool.Parent = LocalPlayer.Backpack
            initGrab()
        else
            GrabTool.Parent = nil
        end
    end,
})

-- =========================================================
-- AUTO STOMP + STOMP EFFECT
-- =========================================================
local function stompEffectFor(targetChar)
    local now = tick()
    if now - lastStompTime < STOMP_COOLDOWN then return end
    lastStompTime = now

    if STOMP_EFFECT == "Spirit" then
        local aura = Instance.new("Part")
        aura.Size = Vector3.new(10, 10, 10)
        aura.Anchored = true
        aura.CanCollide = false
        aura.Transparency = 0.3
        aura.Material = Enum.Material.ForceField
        aura.Color = Color3.fromRGB(4, 175, 236)
        aura.Position = targetChar:FindFirstChild("UpperTorso") and targetChar.UpperTorso.Position or targetChar.HumanoidRootPart.Position
        aura.Parent = Workspace
        TweenService:Create(aura, TweenInfo.new(2), {
            Position = aura.Position + Vector3.new(0, 50, 0),
            Size = Vector3.new(120, 90, 120),
            Transparency = 1,
        }):Play()
        for _, p in ipairs(targetChar:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then
                TweenService:Create(p, TweenInfo.new(0.5), {Transparency = 1}):Play()
            end
        end
        task.delay(2, function() if aura.Parent then aura:Destroy() end end)
    elseif STOMP_EFFECT == "Rings" then
        local ring = Instance.new("Part")
        ring.Size = Vector3.new(1, 0.1, 1)
        ring.Anchored = true
        ring.CanCollide = false
        ring.Material = Enum.Material.Neon
        ring.Color = Color3.fromRGB(255, 255, 255)
        ring.Transparency = 0.3
        ring.Position = targetChar.Head.Position
        ring.Parent = Workspace
        TweenService:Create(ring, TweenInfo.new(1), {Size = Vector3.new(40, 0.1, 40), Transparency = 1}):Play()
        task.delay(1.2, function() if ring.Parent then ring:Destroy() end end)
    elseif STOMP_EFFECT == "BlackHole" then
        local hole = Instance.new("Part")
        hole.Shape = Enum.PartType.Ball
        hole.Size = Vector3.new(6, 6, 6)
        hole.Anchored = true
        hole.CanCollide = false
        hole.Material = Enum.Material.Neon
        hole.Color = Color3.fromRGB(0, 0, 0)
        hole.Position = targetChar.UpperTorso.Position + Vector3.new(0, 1, 0)
        hole.Parent = Workspace
        for _, p in ipairs(targetChar:GetChildren()) do
            if p:IsA("BasePart") then
                TweenService:Create(p, TweenInfo.new(1.4), {Position = hole.Position}):Play()
            end
        end
        task.delay(1.5, function() if hole.Parent then hole:Destroy() end end)
    elseif STOMP_EFFECT == "Charm" then
        local p = Instance.new("Part")
        p.Anchored = true
        p.CanCollide = false
        p.Transparency = 1
        p.Position = targetChar.UpperTorso.Position
        p.Parent = Workspace
        local a = Instance.new("Attachment", p)
        local e = Instance.new("ParticleEmitter", a)
        e.Brightness = 4
        e.Color = ColorSequence.new(Color3.fromRGB(255, 42, 191))
        e.Lifetime = NumberRange.new(0.5)
        e.Rate = 100
        e.Speed = NumberRange.new(5, 15)
        e.SpreadAngle = Vector2.new(360, 360)
        e.Size = NumberSequence.new(1.5)
        e.Texture = "rbxassetid://4509687978"
        e.Enabled = true
        for _, part in ipairs(targetChar:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                TweenService:Create(part, TweenInfo.new(0.5), {Transparency = 1}):Play()
            end
        end
        task.delay(1.5, function() if p.Parent then p:Destroy() end end)
    elseif STOMP_EFFECT == "Thanos" then
        for _, part in ipairs(targetChar:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                TweenService:Create(part, TweenInfo.new(0.5), {Transparency = 1}):Play()
            end
        end
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://3050376525"
        s.Parent = Workspace
        s:Play()
        s.Ended:Connect(function() s:Destroy() end)
    elseif STOMP_EFFECT == "Afterslash" then
        local p = Instance.new("Part")
        p.Anchored = true
        p.CanCollide = false
        p.Transparency = 1
        p.Position = targetChar.UpperTorso.Position + Vector3.new(0, 5, 0)
        p.Parent = Workspace
        for _, part in ipairs(targetChar:GetDescendants()) do
            if part:IsA("BasePart") then
                TweenService:Create(part, TweenInfo.new(0.5), {Transparency = 1}):Play()
            end
        end
        task.delay(1.5, function() if p.Parent then p:Destroy() end end)
    elseif STOMP_EFFECT == "RoadRoller" then
        local roller = Instance.new("Part")
        roller.Size = Vector3.new(8, 8, 8)
        roller.Anchored = true
        roller.CanCollide = false
        roller.Material = Enum.Material.Metal
        roller.Color = Color3.fromRGB(80, 80, 80)
        roller.Position = targetChar.HumanoidRootPart.Position + Vector3.new(0, 40, 0)
        roller.Parent = Workspace
        TweenService:Create(roller, TweenInfo.new(0.2), {
            Position = targetChar.HumanoidRootPart.Position + Vector3.new(0, 3, 0),
        }):Play()
        task.delay(2, function() if roller.Parent then roller:Destroy() end end)
    end
end

Group:AddToggle('AutoStompAura', {
    Text = 'Stomp Aura',
    Default = false,
    Callback = function(v) Config.KillAura.StompAura = v end,
})

local StompEffectsGroup = Tabs.Visual:AddLeftGroupbox("Stomp Effects")
StompEffectsGroup:AddToggle('StompEffectsEnabled', {
    Text = 'Stompeffects',
    Default = false,
    Callback = function(v) end,
})
StompEffectsGroup:AddDropdown('StompEffectSelect', {
    Text = 'Select stomp effect',
    Values = {"Spirit", "RoadRoller", "Rings", "BlackHole", "Charm", "Thanos", "Afterslash"},
    Default = "Thanos",
    Multi = false,
    Callback = function(v) STOMP_EFFECT = v end,
})

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("LowerTorso") or not char:FindFirstChild("UpperTorso") then return end
    local origin = char.LowerTorso.Position
    local dir = Vector3.new(0, -char.UpperTorso.Size.Y * 4.5, 0)
    local whitelist = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            table.insert(whitelist, p.Character)
        end
    end
    if #whitelist == 0 then return end
    local hitPart = Workspace:FindPartOnRayWithWhitelist(Ray.new(origin, dir), whitelist, false, true)
    if hitPart then
        local stomped = hitPart:FindFirstAncestorOfClass("Model")
        if stomped and stomped:FindFirstChild("BodyEffects")
            and stomped.BodyEffects:FindFirstChild("SDeath")
            and stomped.BodyEffects.SDeath.Value then
            stompEffectFor(stomped)
        end
    end
end)

-- =========================================================
-- Simple trolling tools (rope / pivot based)
-- =========================================================
local toolStates = {
    Up          = false,
    Air         = false,
    Throw       = false,
    HeavenThrow = false,
    Punch       = false,
    RipInHalf   = false,
    Void        = false,
    Orbit       = false,
}

local orbitRunning = false
local orbitConn

local function getGrabbedChar()
    local be = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("BodyEffects")
    if not be then return nil end
    local g = be:FindFirstChild("Grabbed")
    return g and g.Value or nil
end

local function makeTool(name, onActivate)
    local t = Instance.new("Tool")
    t.Name = name
    t.RequiresHandle = false
    t.Parent = LocalPlayer.Backpack
    t.Activated:Connect(function()
        if not grabbed then return end
        local target = getGrabbedChar()
        if not target then return end
        onActivate(target)
    end)
    return t
end

local function ensureBody(targetTorso)
    if not targetTorso:FindFirstChild("BodyPosition") then
        local bp = Instance.new("BodyPosition")
        bp.Name = "BodyPosition"
        bp.D = 200
        bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bp.Parent = targetTorso
    end
    if not targetTorso:FindFirstChild("BodyGyro") then
        local bg = Instance.new("BodyGyro")
        bg.Name = "BodyGyro"
        bg.D = 100
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.Parent = targetTorso
    end
    return targetTorso.BodyPosition, targetTorso.BodyGyro
end

local function createUpTool()
    return makeTool("Up", function(target)
        local char = LocalPlayer.Character
        local up = target:FindFirstChild("UpperTorso")
        if not up then return end
        local bp, bg = ensureBody(up)
        bp.D = 1200
        RunService.Heartbeat:Connect(function()
            if not up.Parent or not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            bp.Position = hrp.Position + hrp.CFrame.LookVector * 8 + Vector3.new(0, 23, 0)
            bg.CFrame = CFrame.new(up.Position, hrp.Position)
        end)
    end)
end

local function createAirTool()
    return makeTool("Air", function(target)
        local char = LocalPlayer.Character
        local up = target:FindFirstChild("UpperTorso")
        if not up then return end
        local bp, bg = ensureBody(up)
        bp.D = 1200
        RunService.Heartbeat:Connect(function()
            if not up.Parent or not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            bp.Position = hrp.Position - hrp.CFrame.LookVector * 5 + Vector3.new(0, 9, 0)
            bg.CFrame = CFrame.new(up.Position, hrp.Position)
        end)
    end)
end

local function createThrowTool()
    return makeTool("Throw", function(target)
        local up = target:FindFirstChild("UpperTorso")
        if not up then return end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bp, bg = ensureBody(up)
        bp.D = 900
        if bg then bg:Destroy() end
        bp.Position = hrp.Position + hrp.CFrame.LookVector * 150 + Vector3.new(0, 5, 0)
        task.wait(0.5)
        if bp and bp.Parent then bp:Destroy() end
        if Remote.MainEvent then Remote.MainEvent:FireServer("Grabbing", false) end
    end)
end

local function createHeavenThrowTool()
    return makeTool("Heaven Throw", function(target)
        local up = target:FindFirstChild("UpperTorso")
        if not up then return end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bp, bg = ensureBody(up)
        if bg then bg:Destroy() end
        bp.D = 200
        bp.Position = hrp.Position + hrp.CFrame.LookVector * 3 + Vector3.new(0, 3000, 0)
        task.wait(2)
        if Remote.MainEvent then Remote.MainEvent:FireServer("Grabbing", false) end
    end)
end

local function createPunchTool()
    return makeTool("Punch", function(target)
        local char = LocalPlayer.Character
        local up = target:FindFirstChild("UpperTorso")
        if not up or not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bp, bg = ensureBody(up)
        bp.D = 3400
        bp.Position = hrp.Position + hrp.CFrame.LookVector * 3 + Vector3.new(0, 1, 0)
        task.wait(3)
        if bp then bp:Destroy() end
        if bg then bg:Destroy() end
        up.Velocity = Vector3.new(hrp.CFrame.LookVector.X * 950, -200, hrp.CFrame.LookVector.Z * 950)
        task.wait(1)
        if Remote.MainEvent then Remote.MainEvent:FireServer("Grabbing", false) end
    end)
end

local function createRipInHalfTool()
    return makeTool("Rip In Half", function(target)
        local char = LocalPlayer.Character
        local up = target:FindFirstChild("UpperTorso")
        local low = target:FindFirstChild("LowerTorso")
        if not up or not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bp = ensureBody(up)
        task.wait(0.2)
        if low then low.Position = Vector3.new(0, -1200, 0) end
        task.wait(0.2)
        if bp then bp:Destroy() end
        up.Velocity = hrp.CFrame.RightVector * 90
        if target:FindFirstChild("RightUpperLeg") then target.RightUpperLeg.Velocity = hrp.CFrame.RightVector * -90 end
        if target:FindFirstChild("LeftUpperLeg") then target.LeftUpperLeg.Velocity = hrp.CFrame.RightVector * -90 end
        task.wait(0.3)
        if Remote.MainEvent then Remote.MainEvent:FireServer("Grabbing", false) end
    end)
end

local function createVoidTool()
    return makeTool("Void", function(target)
        local char = LocalPlayer.Character
        local up = target:FindFirstChild("UpperTorso")
        if not up or not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bp = ensureBody(up)
        bp.D = 1200
        bp.Position = hrp.Position + hrp.CFrame.LookVector * 4 + Vector3.new(0, 1.4, 0)
        task.wait(2)
        if bp then bp:Destroy() end
        for _, v in ipairs(target:GetChildren()) do
            if v:IsA("MeshPart") then v.Position = Vector3.new(0, -600, 0) end
        end
        if Remote.MainEvent then Remote.MainEvent:FireServer("Grabbing", false) end
    end)
end

local function createOrbitTool()
    return makeTool("Orbit", function(target)
        local char = LocalPlayer.Character
        local up = target:FindFirstChild("UpperTorso")
        if not up or not char then return end
        local bp, bg = ensureBody(up)
        if orbitRunning then
            orbitRunning = false
            if orbitConn then orbitConn:Disconnect() end
            return
        end
        orbitRunning = true
        local theta = 0
        bp.D = 1200
        if orbitConn then orbitConn:Disconnect() end
        orbitConn = RunService.RenderStepped:Connect(function()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp or not up.Parent then
                orbitRunning = false
                if orbitConn then orbitConn:Disconnect() end
                return
            end
            theta += 0.6
            local offset = Vector3.new(math.cos(theta) * 20, 3, math.sin(theta) * 20)
            bp.Position = hrp.Position + offset
            bg.CFrame = CFrame.new(up.Position, hrp.Position)
        end)
    end)
end

local function removeTool(name)
    local t1 = LocalPlayer.Backpack:FindFirstChild(name)
    if t1 then t1:Destroy() end
    if LocalPlayer.Character then
        local t2 = LocalPlayer.Character:FindFirstChild(name)
        if t2 then t2:Destroy() end
    end
end

local function setupTool(name, enable, creator)
    toolStates[name] = enable
    if enable then creator()
    else removeTool(name) end
end

Group:AddToggle('UpToggle', {
    Text = 'Up',
    Default = false,
    Callback = function(v) setupTool("Up", v, createUpTool) end,
})
Group:AddToggle('AirToggle', {
    Text = 'Air',
    Default = false,
    Callback = function(v) setupTool("Air", v, createAirTool) end,
})
Group:AddToggle('ThrowToggle', {
    Text = 'Throw',
    Default = false,
    Callback = function(v) setupTool("Throw", v, createThrowTool) end,
})
Group:AddToggle('HeavenThrowToggle', {
    Text = 'Heaven Throw',
    Default = false,
    Callback = function(v) setupTool("Heaven Throw", v, createHeavenThrowTool) end,
})
Group:AddToggle('PunchToggle', {
    Text = 'Punch',
    Default = false,
    Callback = function(v) setupTool("Punch", v, createPunchTool) end,
})
Group:AddToggle('RipInHalfToggle', {
    Text = 'Rip In Half',
    Default = false,
    Callback = function(v) setupTool("Rip In Half", v, createRipInHalfTool) end,
})
Group:AddToggle('VoidToggle', {
    Text = 'Void',
    Default = false,
    Callback = function(v) setupTool("Void", v, createVoidTool) end,
})
Group:AddToggle('OrbitToggle', {
    Text = 'Orbit',
    Default = false,
    Callback = function(v) setupTool("Orbit", v, createOrbitTool) end,
})

-- Respaww rebuild
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    if toolStates.Up then createUpTool() end
    if toolStates.Air then createAirTool() end
    if toolStates.Throw then createThrowTool() end
    if toolStates.HeavenThrow then createHeavenThrowTool() end
    if toolStates.Punch then createPunchTool() end
    if toolStates.RipInHalf then createRipInHalfTool() end
    if toolStates.Void then createVoidTool() end
    if toolStates.Orbit then createOrbitTool() end
end)

return Trolling