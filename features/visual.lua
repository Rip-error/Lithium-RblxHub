local Visual = {}

local Config  = require(script.Parent.Parent.core.config)
local Helpers = require(script.Parent.Parent.core.helpers)

local Players          = Helpers.Players
local LocalPlayer      = Helpers.LocalPlayer
local RunService       = Helpers.RunService
local UserInputService = Helpers.UserInputService
local Camera           = Helpers.Camera
local Workspace        = Helpers.Workspace
local TweenService     = game:GetService("TweenService")

local Tabs = _G.LITHIUM.Tabs

-- =====================================================
-- Crosshair
-- =====================================================
local CrosshairGroup = Tabs.Visual:AddRightGroupbox('Crosshair')
local crosshairState = {
    Enabled = false,
    FollowTarget = false,
    TextOn = true,
    SpinSpeed = 0.8,
    LineLength = 25,
    Rainbow = false,
    Color = Color3.fromRGB(255, 255, 255),
}

local screenGui, container, topLine, bottomLine, leftLine, rightLine, textLabel
local time, rotationProgress, currentRotationSpeed, smoothedRotation = 0, 0, 0.8, 5
local lineLength, lineThickness = 25, 3
local baseRotationSpeed = 0.8
local pulseSpeed = 2.5
local minLength, maxLength = -10, -30
local smoothed, isFollow = 5, false

local function buildGui()
    if screenGui then screenGui:Destroy() end
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LithiumCrosshair"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(0, 25, 0, 25)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.Parent = screenGui

    local function mkLine(size, pos, color)
        local f = Instance.new("Frame")
        f.Size = size
        f.Position = pos
        f.BackgroundColor3 = color
        f.BorderSizePixel = 0
        f.ZIndex = 5
        f.Parent = container
        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(0, 0, 0)
        s.Thickness = 1
        s.Parent = f
        return f
    end

    topLine    = mkLine(UDim2.new(0, 3, 0, 25), UDim2.new(0.5, -1.5, 0, 0),        crosshairState.Color)
    bottomLine = mkLine(UDim2.new(0, 3, 0, 25), UDim2.new(0.5, -1.5, 1, -25),      crosshairState.Color)
    leftLine   = mkLine(UDim2.new(0, 25, 0, 3), UDim2.new(0, 0, 0.5, -1.5),        crosshairState.Color)
    rightLine  = mkLine(UDim2.new(0, 25, 0, 3), UDim2.new(1, -25, 0.5, -1.5),      crosshairState.Color)

    textLabel = Instance.new("TextLabel")
    textLabel.Text = "Lithium"
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(0, 150, 0, 23)
    textLabel.Font = Enum.Font.Arcade
    textLabel.TextScaled = true
    textLabel.TextColor3 = crosshairState.Color
    textLabel.ZIndex = 10
    textLabel.Visible = crosshairState.TextOn
    textLabel.Parent = screenGui
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(0, 0, 0)
    s.Thickness = 1
    s.Parent = textLabel
end

local function rainbow(t)
    return Color3.new(
        math.sin(t * 0.6) * 0.5 + 0.5,
        math.sin(t * 0.6 + 2) * 0.5 + 0.5,
        math.sin(t * 0.6 + 4) * 0.5 + 0.5
    )
end

local mouse = LocalPlayer:GetMouse()

RunService.RenderStepped:Connect(function(dt)
    if not crosshairState.Enabled or not container then return end
    time += dt

    local mx, my = mouse.X, mouse.Y
    local tx, ty = mx, my

    if crosshairState.FollowTarget and Config.TargetAim.Target ~= "None" then
        local target = Players:FindFirstChild(Config.TargetAim.Target)
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild("UpperTorso")
                or target.Character:FindFirstChild("HumanoidRootPart")
            if aimPart then
                local sp, onScreen = Camera:WorldToScreenPoint(aimPart.Position)
                if onScreen then tx, ty = sp.X, sp.Y end
            end
        end
    end

    container.Position = UDim2.new(0, tx, 0, ty)
    textLabel.Position = UDim2.new(0, tx - 70, 0, ty + 50)

    rotationProgress = (rotationProgress + baseRotationSpeed * dt) % 1
    local targetRot = rotationProgress * 360
    smoothed = smoothed + (targetRot - smoothed) * 1
    container.Rotation = smoothed

    local pulse = (math.sin(time * pulseSpeed) * 0.5 + 0.5)
    pulse = pulse * pulse
    local curLen = minLength + (maxLength - minLength) * pulse

    topLine.Size    = UDim2.new(0, lineThickness, 0, curLen)
    bottomLine.Size = UDim2.new(0, lineThickness, 0, curLen)
    leftLine.Size   = UDim2.new(0, curLen, 0, lineThickness)
    rightLine.Size  = UDim2.new(0, curLen, 0, lineThickness)

    topLine.Position    = UDim2.new(0.5, -lineThickness / 2, 0, 0)
    bottomLine.Position = UDim2.new(0.5, -lineThickness / 2, 1, -curLen)
    leftLine.Position   = UDim2.new(0, 0, 0.5, -lineThickness / 2)
    rightLine.Position  = UDim2.new(1, -curLen, 0.5, -lineThickness / 2)

    local color = crosshairState.Rainbow and rainbow(time) or crosshairState.Color
    topLine.BackgroundColor3 = color
    bottomLine.BackgroundColor3 = color
    leftLine.BackgroundColor3 = color
    rightLine.BackgroundColor3 = color
    textLabel.TextColor3 = color
end)

CrosshairGroup:AddToggle('CrosshairEnabled', {
    Text = 'Enabled',
    Default = false,
    Callback = function(v)
        crosshairState.Enabled = v
        if v then buildGui() elseif screenGui then screenGui:Destroy() screenGui = nil end
    end,
}):AddColorPicker('CrosshairColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Color',
    Callback = function(c) crosshairState.Color = c end,
})
CrosshairGroup:AddToggle('CrosshairFollowTarget', {
    Text = 'Follow Target',
    Default = false,
    Callback = function(v) crosshairState.FollowTarget = v end,
})
CrosshairGroup:AddToggle('CrosshairText', {
    Text = 'Text',
    Default = true,
    Callback = function(v)
        crosshairState.TextOn = v
        if textLabel then textLabel.Visible = v end
    end,
})
CrosshairGroup:AddSlider('CrosshairSpinSpeed', {
    Text = 'Spin Speed',
    Default = 0.8, Min = 0.1, Max = 2, Rounding = 2,
    Callback = function(v) baseRotationSpeed = v end,
})
CrosshairGroup:AddSlider('CrosshairLineLength', {
    Text = 'Line Length',
    Default = 25, Min = 5, Max = 100, Rounding = 1,
    Callback = function(v)
        lineLength = v
        minLength = -v * 0.4
        maxLength = -v * 1.2
    end,
})
CrosshairGroup:AddToggle('CrosshairRainbow', {
    Text = 'Rainbow',
    Default = false,
    Callback = function(v) crosshairState.Rainbow = v end,
})

-- =====================================================
-- Rain + Snow
-- =====================================================
local RainGroup = Tabs.Visual:AddRightGroupbox('Rain / Snow')
local rainCfg   = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Lifetime = 5, Rate = 1000, Speed = 100 }
local snowCfg   = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Rate = 100, Speed = 10 }
local rainPart, rainEmitter, rainConn
local snowPart, snowEmitter, snowConn

local function buildRain()
    if rainPart then rainPart:Destroy() end
    rainPart = Instance.new("Part")
    rainPart.Size = Vector3.new(51.8, 0.001, 52.084)
    rainPart.CanCollide = false
    rainPart.Anchored = true
    rainPart.Transparency = 1
    rainPart.Parent = Workspace

    rainEmitter = Instance.new("ParticleEmitter")
    rainEmitter.Color = ColorSequence.new(rainCfg.Color)
    rainEmitter.LightEmission = 1
    rainEmitter.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
    rainEmitter.Size = NumberSequence.new(0.4)
    rainEmitter.Squash = NumberSequence.new(4)
    rainEmitter.Texture = "rbxassetid://129110349"
    rainEmitter.EmissionDirection = Enum.NormalId.Bottom
    rainEmitter.Lifetime = NumberRange.new(rainCfg.Lifetime)
    rainEmitter.Rate = rainCfg.Rate
    rainEmitter.Speed = NumberRange.new(rainCfg.Speed)
    rainEmitter.LockedToPart = true
    rainEmitter.Enabled = true
    rainEmitter.Parent = rainPart
end

local function buildSnow()
    if snowPart then snowPart:Destroy() end
    snowPart = Instance.new("Part")
    snowPart.Size = Vector3.new(51.8, 0.001, 52.084)
    snowPart.Anchored = true
    snowPart.CanCollide = false
    snowPart.Transparency = 1
    snowPart.Parent = Workspace

    snowEmitter = Instance.new("ParticleEmitter")
    snowEmitter.Color = ColorSequence.new(snowCfg.Color)
    snowEmitter.EmissionDirection = Enum.NormalId.Bottom
    snowEmitter.Enabled = true
    snowEmitter.Lifetime = NumberRange.new(5, 100)
    snowEmitter.Rate = snowCfg.Rate
    snowEmitter.RotSpeed = NumberRange.new(360, 360)
    snowEmitter.Rotation = NumberRange.new(20, 20)
    snowEmitter.Shape = Enum.ParticleEmitterShape.Box
    snowEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2, 0.4),
        NumberSequenceKeypoint.new(1, 0.2, 0.4),
    })
    snowEmitter.Speed = NumberRange.new(snowCfg.Speed)
    snowEmitter.SpreadAngle = Vector2.new(90, 90)
    snowEmitter.Texture = "rbxassetid://129110349"
    snowEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8625),
        NumberSequenceKeypoint.new(0.15, 0),
        NumberSequenceKeypoint.new(0.196326, 0.70625),
        NumberSequenceKeypoint.new(1, 0),
    })
    snowEmitter.Parent = snowPart
end

RunService.Heartbeat:Connect(function()
    if rainCfg.Enabled and rainPart then
        rainPart.CFrame = CFrame.new(Camera.CFrame.Position + Vector3.new(0, 30, 0))
    end
    if snowCfg.Enabled and snowPart then
        snowPart.CFrame = CFrame.new(Camera.CFrame.Position + Vector3.new(0, 5, 0))
    end
end)

RainGroup:AddToggle('RainEnabled', {
    Text = 'Rain',
    Default = false,
    Callback = function(v)
        rainCfg.Enabled = v
        if v then buildRain()
        elseif rainPart then rainPart:Destroy() rainPart = nil rainEmitter = nil end
    end,
}):AddColorPicker('RainColor', {
    Default = rainCfg.Color,
    Title = 'Rain Color',
    Callback = function(c) rainCfg.Color = c if rainCfg.Enabled then buildRain() end end,
})
RainGroup:AddSlider('RainRate', {
    Text = 'Amount',
    Default = 1000, Min = 1, Max = 10000, Rounding = 0,
    Callback = function(v) rainCfg.Rate = v if rainCfg.Enabled then buildRain() end end,
})
RainGroup:AddSlider('RainSpeed', {
    Text = 'Speed',
    Default = 100, Min = 10, Max = 1000, Rounding = 0,
    Callback = function(v) rainCfg.Speed = v if rainCfg.Enabled then buildRain() end end,
})
RainGroup:AddToggle('SnowEnabled', {
    Text = 'Snow',
    Default = false,
    Callback = function(v)
        snowCfg.Enabled = v
        if v then buildSnow()
        elseif snowPart then snowPart:Destroy() snowPart = nil snowEmitter = nil end
    end,
}):AddColorPicker('SnowColor', {
    Default = snowCfg.Color,
    Title = 'Snow Color',
    Callback = function(c) snowCfg.Color = c if snowCfg.Enabled then buildSnow() end end,
})
RainGroup:AddSlider('SnowRate', {
    Text = 'Snow Amount',
    Default = 100, Min = 1, Max = 1000, Rounding = 0,
    Callback = function(v) snowCfg.Rate = v if snowCfg.Enabled then buildSnow() end end,
})
RainGroup:AddSlider('SnowSpeed', {
    Text = 'Snow Speed',
    Default = 10, Min = 1, Max = 1000, Rounding = 0,
    Callback = function(v) snowCfg.Speed = v if snowCfg.Enabled then buildSnow() end end,
})

-- =====================================================
-- Aura Safe
-- =====================================================
local AuraGroup = Tabs.Visual:AddLeftGroupbox('Aura')

local auraColor = Color3.fromRGB(255, 255, 255)
local auraEnabled = false

local function buildAura(character)
    if not character then return end
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if not torso then return end
    local old = torso:FindFirstChild("LithiumAura")
    if old then old:Destroy() end
    local folder = Instance.new("Folder")
    folder.Name = "LithiumAura"
    folder.Parent = torso

    local light = Instance.new("PointLight")
    light.Range = 5
    light.Brightness = 3
    light.Color = auraColor
    light.Parent = folder

    local a1 = Instance.new("Attachment")
    a1.Name = "Upper"
    a1.CFrame = CFrame.new(0, 2.125, 0)
    a1.Parent = folder

    local a2 = Instance.new("Attachment")
    a2.Name = "Lower"
    a2.CFrame = CFrame.new(0, -3, 0)
    a2.Parent = folder

    local beam = Instance.new("Beam")
    beam.Attachment0 = a2
    beam.Attachment1 = a1
    beam.Brightness = 1
    beam.Color = ColorSequence.new(auraColor)
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.Segments = 10
    beam.Texture = "rbxassetid://7673945506"
    beam.TextureLength = 0.3
    beam.TextureSpeed = 2
    beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    beam.Width0 = 6
    beam.Width1 = 6
    beam.ZOffset = 1
    beam.Parent = folder
end

local function removeAura(character)
    if not character then return end
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if not torso then return end
    local f = torso:FindFirstChild("LithiumAura")
    if f then f:Destroy() end
end

LocalPlayer.CharacterAdded:Connect(function(c)
    if auraEnabled then
        task.wait(0.5)
        buildAura(c)
    end
end)

AuraGroup:AddToggle('AuraEnabled', {
    Text = 'Aura Safe',
    Default = false,
    Callback = function(v)
        auraEnabled = v
        if v then buildAura(LocalPlayer.Character)
        else removeAura(LocalPlayer.Character) end
    end,
}):AddColorPicker('AuraColor', {
    Default = auraColor,
    Title = 'Aura Color',
    Callback = function(c)
        auraColor = c
        if auraEnabled then
            removeAura(LocalPlayer.Character)
            buildAura(LocalPlayer.Character)
        end
    end,
})

-- =====================================================
-- China Hat
-- =====================================================
local HatGroup = Tabs.Visual:AddRightGroupbox('China Hat')
local hatState = {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    LightColor = Color3.fromRGB(255, 255, 255),
    Brightness = 0,
    Range = 12,
    Scale = Vector3.new(1.7, 1.1, 1.7),
}

local function buildHat(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    local old = char:FindFirstChild("LithiumHat")
    if old then old:Destroy() end
    local cone = Instance.new("Part")
    cone.Name = "LithiumHat"
    cone.Size = Vector3.new(1, 1, 1)
    cone.Material = Enum.Material.Neon
    cone.Transparency = 0.2
    cone.Anchored = false
    cone.CanCollide = false
    cone.Color = hatState.Color
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = hatState.Scale
    mesh.Parent = cone
    local w = Instance.new("Weld")
    w.Part0 = head
    w.Part1 = cone
    w.C0 = CFrame.new(0, 0.9, 0)
    w.Parent = cone
    local l = Instance.new("PointLight")
    l.Color = hatState.LightColor
    l.Brightness = hatState.Brightness
    l.Range = hatState.Range
    l.Shadows = true
    l.Parent = cone
    cone.Parent = char
end

local function removeHat()
    local char = LocalPlayer.Character
    if char then
        local h = char:FindFirstChild("LithiumHat")
        if h then h:Destroy() end
    end
end

LocalPlayer.CharacterAdded:Connect(function(c)
    if hatState.Enabled then
        task.wait(3)
        buildHat(c)
    end
end)

HatGroup:AddToggle('ChinaHatEnabled', {
    Text = 'Vietnam Hat',
    Default = false,
    Callback = function(v)
        hatState.Enabled = v
        if v then buildHat(LocalPlayer.Character) else removeHat() end
    end,
}):AddColorPicker('ChinaHatColor', {
    Default = hatState.Color,
    Title = 'Hat Color',
    Callback = function(c)
        hatState.Color = c
        if hatState.Enabled then removeHat() buildHat(LocalPlayer.Character) end
    end,
}):AddColorPicker('ChinaLightColor', {
    Default = hatState.LightColor,
    Title = 'Light Color',
    Callback = function(c)
        hatState.LightColor = c
        if hatState.Enabled then removeHat() buildHat(LocalPlayer.Character) end
    end,
})
HatGroup:AddSlider('ChinaLightBrightness', {
    Text = 'Light Brightness',
    Default = 0, Min = 0, Max = 10, Rounding = 1,
    Callback = function(v)
        hatState.Brightness = v
        if hatState.Enabled then removeHat() buildHat(LocalPlayer.Character) end
    end,
})
HatGroup:AddSlider('ChinaLightRange', {
    Text = 'Light Range',
    Default = 12, Min = 0, Max = 50, Rounding = 0,
    Callback = function(v)
        hatState.Range = v
        if hatState.Enabled then removeHat() buildHat(LocalPlayer.Character) end
    end,
})

-- =====================================================
-- Bullet Tracers
-- =====================================================
local BtGroup = Tabs.Visual:AddLeftGroupbox('Bullet Tracers')
local btCfg = {
    Enabled = false,
    TextureID = "rbxassetid://12781852245",
    Color = Color3.fromRGB(255, 255, 255),
    Size = 0.4,
    Transparency = 0,
    TimeAlive = 3,
}

local function bulletTracer(startPos, endPos)
    local startPart = Instance.new("Part")
    startPart.Anchored = true
    startPart.CanCollide = false
    startPart.Transparency = 1
    startPart.Size = Vector3.new(0.2, 0.2, 0.2)
    startPart.Position = startPos
    startPart.Parent = Workspace

    local endPart = Instance.new("Part")
    endPart.Anchored = true
    endPart.CanCollide = false
    endPart.Transparency = 1
    endPart.Size = Vector3.new(0.2, 0.2, 0.2)
    endPart.Position = endPos
    endPart.Parent = Workspace

    local beam = Instance.new("Beam")
    beam.Attachment0 = Instance.new("Attachment", startPart)
    beam.Attachment1 = Instance.new("Attachment", endPart)
    beam.Parent = startPart
    beam.FaceCamera = true
    beam.Color = ColorSequence.new(btCfg.Color)
    beam.Texture = btCfg.TextureID
    beam.LightEmission = 1
    beam.Transparency = NumberSequence.new(btCfg.Transparency)
    beam.Width0 = btCfg.Size
    beam.Width1 = btCfg.Size

    task.delay(btCfg.TimeAlive, function()
        if beam and beam.Parent then
            TweenService:Create(beam, TweenInfo.new(0.3), {Width0 = 0, Width1 = 0}):Play()
        end
        task.wait(0.35)
        if startPart then startPart:Destroy() end
        if endPart then endPart:Destroy() end
    end)
end

local Remote = _G.LITHIUM.Remote
if getnamecallmethod and Remote.MainEvent then
    local mt = getrawmetatable(Remote.MainEvent)
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        if getnamecallmethod() == "FireServer" and args[1] == "ShootGun" and btCfg.Enabled then
            pcall(function()
                bulletTracer(args[3], args[4])
            end)
        end
        return old(self, ...)
    end)
end

BtGroup:AddToggle('BulletTracersEnabled', {
    Text = 'Enabled',
    Default = false,
    Callback = function(v) btCfg.Enabled = v end,
}):AddColorPicker('BulletTracersColor', {
    Default = btCfg.Color,
    Title = 'Color',
    Callback = function(c) btCfg.Color = c end,
})
BtGroup:AddDropdown('BulletTracersTexture', {
    Values = {"Beam", "Lightning", "Heartrate", "Chain", "Glitch", "Swirl"},
    Default = "Beam",
    Multi = false,
    Text = 'Texture',
    Callback = function(v)
        if v == "Beam" then btCfg.TextureID = "rbxassetid://12781852245"
        elseif v == "Lightning" then btCfg.TextureID = "rbxassetid://446111271"
        elseif v == "Heartrate" then btCfg.TextureID = "rbxassetid://5830549480"
        elseif v == "Chain" then btCfg.TextureID = "rbxassetid://9632168658"
        elseif v == "Glitch" then btCfg.TextureID = "rbxassetid://8089467613"
        elseif v == "Swirl" then btCfg.TextureID = "rbxassetid://5638168605"
        end
    end,
})
BtGroup:AddSlider('BulletTracersSize', {
    Text = 'Size',
    Default = 0.4, Min = 0.1, Max = 3, Rounding = 2,
    Callback = function(v) btCfg.Size = v end,
})
BtGroup:AddSlider('BulletTracersTransparency', {
    Text = 'Transparency',
    Default = 0, Min = 0, Max = 1, Rounding = 2,
    Callback = function(v) btCfg.Transparency = v end,
})
BtGroup:AddSlider('BulletTracersTimeAlive', {
    Text = 'Time Alive',
    Default = 3, Min = 1, Max = 10, Rounding = 0,
    Callback = function(v) btCfg.TimeAlive = v end,
})

-- =====================================================
-- HUD Changer
-- =====================================================
local HudGroup = Tabs.Visual:AddLeftGroupbox('HUD Changer')
local hudCfg = {
    ToggleHP     = false, TextHP    = " Health ",                    ColorHP    = Color3.fromRGB(240, 8, 209),
    ToggleArmor  = false, TextArmor = "                   Armor",   ColorArmor = Color3.fromRGB(96, 8, 238),
    ToggleEnergy = false, TextEnergy= "Dark Energy              ",  ColorEnergy= Color3.fromRGB(196, 10, 243),
}

local function applyHud()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    local main = pg:FindFirstChild("MainScreenGui")
    if not main then return end
    local bar = main:FindFirstChild("Bar")
    if not bar then return end
    if hudCfg.ToggleHP and bar:FindFirstChild("HP") then
        bar.HP.TextLabel.Text = hudCfg.TextHP
        bar.HP.bar.BackgroundColor3 = hudCfg.ColorHP
    end
    if hudCfg.ToggleArmor and bar:FindFirstChild("Armor") then
        bar.Armor.TextLabel.Text = hudCfg.TextArmor
        bar.Armor.bar.BackgroundColor3 = hudCfg.ColorArmor
    end
    if hudCfg.ToggleEnergy and bar:FindFirstChild("Energy") then
        bar.Energy.TextLabel.Text = hudCfg.TextEnergy
        bar.Energy.bar.BackgroundColor3 = hudCfg.ColorEnergy
    end
end

HudGroup:AddToggle('ToggleHP', {
    Text = 'Customize Health',
    Default = false,
    Callback = function(v) hudCfg.ToggleHP = v applyHud() end,
}):AddColorPicker('ColorHP', {
    Text = 'Health Color',
    Default = hudCfg.ColorHP,
    Callback = function(c) hudCfg.ColorHP = c applyHud() end,
})
HudGroup:AddInput('TextHP', {
    Text = 'Health Text',
    Default = hudCfg.TextHP,
    Callback = function(v) hudCfg.TextHP = v applyHud() end,
})
HudGroup:AddToggle('ToggleArmor', {
    Text = 'Customize Armor',
    Default = false,
    Callback = function(v) hudCfg.ToggleArmor = v applyHud() end,
}):AddColorPicker('ColorArmor', {
    Text = 'Armor Color',
    Default = hudCfg.ColorArmor,
    Callback = function(c) hudCfg.ColorArmor = c applyHud() end,
})
HudGroup:AddInput('TextArmor', {
    Text = 'Armor Text',
    Default = hudCfg.TextArmor,
    Callback = function(v) hudCfg.TextArmor = v applyHud() end,
})
HudGroup:AddToggle('ToggleEnergy', {
    Text = 'Customize Energy',
    Default = false,
    Callback = function(v) hudCfg.ToggleEnergy = v applyHud() end,
}):AddColorPicker('ColorEnergy', {
    Text = 'Energy Color',
    Default = hudCfg.ColorEnergy,
    Callback = function(c) hudCfg.ColorEnergy = c applyHud() end,
})
HudGroup:AddInput('TextEnergy', {
    Text = 'Energy Text',
    Default = hudCfg.TextEnergy,
    Callback = function(v) hudCfg.TextEnergy = v applyHud() end,
})

return Visual