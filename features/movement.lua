local Movement = {}

local Config  = require(script.Parent.Parent.core.config)
local Helpers = require(script.Parent.Parent.core.helpers)

local Players          = Helpers.Players
local LocalPlayer      = Helpers.LocalPlayer
local RunService       = Helpers.RunService
local UserInputService = Helpers.UserInputService
local Camera           = Helpers.Camera
local Workspace        = Helpers.Workspace

local Tabs = _G.LITHIUM.Tabs

local Group = Tabs.Character:AddLeftGroupbox('Movement')

-- WalkSpeed / JumpPower
Group:AddToggle('WalkSpeedToggle', {
    Text = 'Walk Speed',
    Default = false,
    Callback = function(v) Config.Movement.WalkSpeedEnabled = v end,
}):AddKeyPicker('WalkSpeedKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Walk Speed',
})
Group:AddSlider('WalkSpeedSlider', {
    Text = 'Speed',
    Default = 16, Min = 1, Max = 1000, Rounding = 0,
    Callback = function(v) Config.Movement.WalkSpeed = v end,
})
Group:AddToggle('JumpPowerToggle', {
    Text = 'Jump Power',
    Default = false,
    Callback = function(v) Config.Movement.JumpPowerEnabled = v end,
}):AddKeyPicker('JumpPowerKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Jump Power',
})
Group:AddSlider('JumpPowerSlider', {
    Text = 'Power',
    Default = 50, Min = 1, Max = 1000, Rounding = 0,
    Callback = function(v) Config.Movement.JumpPower = v end,
})

RunService.Heartbeat:Connect(function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Config.Movement.WalkSpeedEnabled then hum.WalkSpeed = Config.Movement.WalkSpeed end
    if Config.Movement.JumpPowerEnabled then
        hum.JumpPower = Config.Movement.JumpPower
        hum.UseJumpPower = true
    end
end)

-- CFrame Speed
local SpeedCfg = { Enabled = false, Keybind = false, Speed = 20 }
Group:AddToggle('SpeedEnabled', {
    Text = 'Speed (CFrame)',
    Default = false,
    Callback = function(v) SpeedCfg.Enabled = v end,
}):AddKeyPicker('SpeedKey', {
    Default = 'none',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Speed Key',
    Callback = function(v) SpeedCfg.Keybind = v end,
})
Group:AddSlider('SpeedValue', {
    Text = 'Speed Value',
    Default = 20, Min = 1, Max = 100, Rounding = 0,
    Callback = function(v) SpeedCfg.Speed = v end,
})

RunService.Heartbeat:Connect(function(dt)
    if not (SpeedCfg.Enabled and SpeedCfg.Keybind) then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    hrp.CFrame = hrp.CFrame + hum.MoveDirection * SpeedCfg.Speed * dt * 10
end)

-- Fly v1 (simple)
local Fly1Cfg = { Enabled = false, Keybind = false, Speed = 20 }
Group:AddToggle('FlyEnabled', {
    Text = 'Fly (Simple)',
    Default = false,
    Callback = function(v) Fly1Cfg.Enabled = v end,
}):AddKeyPicker('FlyKey', {
    Default = 'none',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Fly Key',
    Callback = function(v) Fly1Cfg.Keybind = v end,
})
Group:AddSlider('FlySpeed', {
    Text = 'Fly Speed',
    Default = 20, Min = 1, Max = 100, Rounding = 0,
    Callback = function(v) Fly1Cfg.Speed = v end,
})

RunService.Heartbeat:Connect(function(dt)
    if not (Fly1Cfg.Enabled and Fly1Cfg.Keybind) then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    local up = (UserInputService:IsKeyDown(Enum.KeyCode.Space) and Fly1Cfg.Speed / 8)
        or (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -Fly1Cfg.Speed / 8)
        or 0
    hrp.CFrame = hrp.CFrame + hum.MoveDirection * dt * Fly1Cfg.Speed * 10 + Vector3.new(0, up, 0)
    hrp.Velocity = (hrp.Velocity * Vector3.new(1, 0, 1)) + Vector3.new(0, 1.9, 0)
end)

-- Fly v2 (BodyVelocity)
local Fly2 = { Enabled = false, Flying = false, Speed = 150, SpeedMult = 1 }

Group:AddToggle('FlightV2_Enabled', {
    Text = 'Fly (Velocity)',
    Default = false,
    Callback = function(v)
        Fly2.Enabled = v
        if not v then
            Fly2.Flying = false
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
            if Workspace:FindFirstChild("LithiumCore") then Workspace.LithiumCore:Destroy() end
        end
    end,
}):AddKeyPicker('FlightV2_Keybind', {
    Default = 'none',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Fly V2 Keybind',
    Callback = function(v)
        if v and Fly2.Enabled then Fly2.Flying = true
        else
            Fly2.Flying = false
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
            if Workspace:FindFirstChild("LithiumCore") then Workspace.LithiumCore:Destroy() end
        end
    end,
})
Group:AddSlider('FlightV2_Speed', {
    Text = 'Fly V2 Speed',
    Default = 150, Min = 10, Max = 1000, Rounding = 0,
    Callback = function(v) Fly2.Speed = v end,
})

RunService.RenderStepped:Connect(function()
    if not Fly2.Flying then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    hum.PlatformStand = true

    local core = Workspace:FindFirstChild("LithiumCore")
    if not core then
        core = Instance.new("Part")
        core.Name = "LithiumCore"
        core.Size = Vector3.new(0.05, 0.05, 0.05)
        core.Transparency = 1
        core.CanCollide = false
        core.Parent = Workspace
        local w = Instance.new("Weld", core)
        w.Part0 = core
        w.Part1 = hrp
        local bv = Instance.new("BodyVelocity", core)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.zero
        local bg = Instance.new("BodyGyro", core)
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 9e4
        bg.CFrame = core.CFrame
    end

    local bv = core:FindFirstChildOfClass("BodyVelocity")
    local bg = core:FindFirstChildOfClass("BodyGyro")
    if not bv or not bg then return end

    local move = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end

    bv.Velocity = move * Fly2.Speed
    bg.CFrame = Camera.CFrame
end)

-- Bunny Hop
local BunnyHop = { Enabled = false, Keybind = false, Speed = 100 }
Group:AddToggle('BunnyHop_Enabled', {
    Text = 'Bunny Hop',
    Default = false,
    Callback = function(v) BunnyHop.Enabled = v end,
}):AddKeyPicker('BunnyHop_Keybind', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Bunny Hop Keybind',
    Callback = function(v) BunnyHop.Keybind = v end,
})
Group:AddSlider('BunnyHop_Speed', {
    Text = 'Bunny Hop Speed',
    Default = 100, Min = 1, Max = 200, Rounding = 0,
    Callback = function(v) BunnyHop.Speed = v end,
})

RunService.RenderStepped:Connect(function()
    if not (BunnyHop.Enabled and BunnyHop.Keybind) then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum.FloorMaterial ~= Enum.Material.Air then
        hum.Jump = true
        local look = Camera.CFrame.LookVector * Vector3.new(1, 0, 1)
        local mv = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv += look end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv -= look end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv += Vector3.new(-look.Z, 0, look.X) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv += Vector3.new(look.Z, 0, -look.X) end
        if mv.Magnitude > 0 then
            hrp.Velocity = Vector3.new(mv.Unit.X * BunnyHop.Speed, hrp.Velocity.Y, mv.Unit.Z * BunnyHop.Speed)
        end
    end
end)

-- SpinBot
local SpinBot = { Enabled = false, Speed = 20 }
Group:AddToggle('SpinBot_Enabled', {
    Text = 'SpinBot',
    Default = false,
    Callback = function(v) SpinBot.Enabled = v end,
}):AddKeyPicker('SpinBot_Keybind', {
    Default = 'none',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'SpinBot Keybind',
})
Group:AddSlider('SpinBot_Speed', {
    Text = 'Spin Speed',
    Default = 20, Min = 1, Max = 100, Rounding = 0,
    Callback = function(v) SpinBot.Speed = v end,
})

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    if not SpinBot.Enabled then
        hum.AutoRotate = true
        return
    end
    hum.AutoRotate = false
    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SpinBot.Speed), 0)
end)

-- Fake Macro (Q emote speed ramp)
local Macro = { Enabled = false, Keybind = Enum.KeyCode.Q, MaxSpeed = 300, Increment = 1.75, EmoteDuration = 1.6, Current = 16, Ready = false }

local macroHumanoid
local function bindMacroHum(char)
    macroHumanoid = char:WaitForChild("Humanoid")
    macroHumanoid.WalkSpeed = 16
    Macro.Current = 16
    Macro.Ready = false
end
if LocalPlayer.Character then bindMacroHum(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(bindMacroHum)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not Macro.Enabled then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode ~= Macro.Keybind then return end
    if not macroHumanoid then return end

    -- Toggle
    if not Macro.Ready and Macro.Current == 16 then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://3189777795"
        local track = macroHumanoid:LoadAnimation(anim)
        track:Play()
        task.delay(Macro.EmoteDuration, function() if track.IsPlaying then track:Stop() end end)
        Macro.Ready = true
    else
        Macro.Current = 16
        macroHumanoid.WalkSpeed = 16
        Macro.Ready = false
    end
end)

RunService.Heartbeat:Connect(function()
    if not Macro.Enabled or not macroHumanoid then return end
    if Macro.Ready then
        Macro.Current = math.min(Macro.Current + Macro.Increment, Macro.MaxSpeed)
        macroHumanoid.WalkSpeed = Macro.Current
    else
        macroHumanoid.WalkSpeed = 16
        Macro.Current = 16
    end
end)

local MacroGroup = Tabs.Character:AddLeftGroupbox('Fake Macro')
MacroGroup:AddToggle('MacroEnabled', {
    Text = 'Fake Macro',
    Default = false,
    Callback = function(v) Macro.Enabled = v end,
}):AddKeyPicker('MacroKeyPicker', {
    Default = 'Q',
    SyncToggleState = false,
    Mode = 'Toggle',
    Text = 'Speed Toggle Keybind',
    ChangedCallback = function(n) Macro.Keybind = n end,
})
MacroGroup:AddSlider('MacroEmoteDuration', {
    Text = 'Emote Duration',
    Default = 1.6, Min = 0, Max = 2.5, Rounding = 2,
    Callback = function(v) Macro.EmoteDuration = v end,
})
MacroGroup:AddSlider('MacroMaxSpeed', {
    Text = 'Max Speed',
    Default = 300, Min = 16, Max = 1000, Rounding = 0,
    Callback = function(v) Macro.MaxSpeed = v end,
})
MacroGroup:AddSlider('MacroIncrement', {
    Text = 'Speed Increment',
    Default = 1.75, Min = 0.1, Max = 10, Rounding = 2,
    Callback = function(v) Macro.Increment = v end,
})

-- Vehicle Fly (kept minimal — reads current car via workspace)
local VFly = { Allowed = true, Flying = false, Speed = 2 }

local function getCar()
    local char = LocalPlayer.Character
    if not char then return nil end
    local seat = char:FindFirstChildOfClass("VehicleSeat")
    if seat and seat.Parent then return seat.Parent end
    return nil
end

Group:AddToggle('VFly', {
    Text = 'Vehicle Fly',
    Default = false,
    Callback = function(v) VFly.Allowed = v end,
}):AddKeyPicker('VehicleFlyKey', {
    Text = 'Vehicle Fly',
    Default = 'F',
    Mode = 'Toggle',
    SyncToggleState = false,
    Callback = function() VFly.Flying = not VFly.Flying end,
})
Group:AddSlider('VFlySpeed', {
    Text = 'Vehicle Fly Speed',
    Default = 2, Min = 1, Max = 20, Rounding = 1,
    Callback = function(v) VFly.Speed = v end,
})

RunService.Heartbeat:Connect(function()
    if not VFly.Flying or not VFly.Allowed then
        local car = getCar()
        if car then
            for _, v in ipairs(car:GetChildren()) do
                if v.Name == "LithiumBV" or v.Name == "LithiumBG" then v:Destroy() end
            end
        end
        return
    end
    local car = getCar()
    if not car then return end
    local bv = car:FindFirstChild("LithiumBV")
    local bg = car:FindFirstChild("LithiumBG")
    if not bv then
        bv = Instance.new("BodyVelocity"); bv.Name = "LithiumBV"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Parent = car
    end
    if not bg then
        bg = Instance.new("BodyGyro"); bg.Name = "LithiumBG"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.P = 9e4; bg.Parent = car
    end
    local move = Vector3.new(
        UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or (UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0),
        UserInputService:IsKeyDown(Enum.KeyCode.Space) and 0.2 or 0,
        UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
    )
    bg.CFrame = CFrame.new(car.Position) * Camera.CFrame.Rotation
    bv.Velocity = (bg.CFrame.LookVector * move.Z + bg.CFrame.RightVector * move.X + Vector3.new(0, move.Y, 0)) * VFly.Speed
end)

return Movement