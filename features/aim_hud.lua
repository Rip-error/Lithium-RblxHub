local healthConns = {}

local statsGui = Instance.new("ScreenGui")
statsGui.Name = "LithiumTargetStats"
statsGui.Parent = game.CoreGui
statsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
statsGui.ResetOnSpawn = false

local bg = Instance.new("Frame")
bg.Name = "Background"
bg.Parent = statsGui
bg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bg.BorderSizePixel = 0
bg.Draggable = true
bg.Active = true
bg.Position = UDim2.new(0.388, 0, 0.700, 0)
bg.Size = UDim2.new(0, 358, 0, 71)
bg.Visible = false

local grad2 = Instance.new("UIGradient")
grad2.Color = ColorSequence.new(Color3.fromRGB(0,200,140), Color3.fromRGB(0,0,0))
grad2.Rotation = 90
grad2.Parent = bg

local pic = Instance.new("ImageLabel")
pic.Parent = bg
pic.BackgroundTransparency = 1
pic.Position = UDim2.new(0.027, 0, 0.070, 0)
pic.Size = UDim2.new(0, 59, 0, 59)

local top = Instance.new("Frame")
top.Parent = bg
top.BackgroundColor3 = Color3.fromRGB(255,255,255)
top.BorderSizePixel = 0
top.Position = UDim2.new(0, 0, -0.101, 0)
top.Size = UDim2.new(0, 358, 0, 7)

local grad1 = Instance.new("UIGradient")
grad1.Color = ColorSequence.new(Color3.fromRGB(0,200,140), Color3.fromRGB(120,255,59))
grad1.Rotation = 90
grad1.Parent = top

local hpBg = Instance.new("Frame")
hpBg.Parent = bg
hpBg.BackgroundTransparency = 1
hpBg.Position = UDim2.new(0.215, 0, 0.348, 0)
hpBg.Size = UDim2.new(0, 270, 0, 19)

local hp = Instance.new("Frame")
hp.Parent = hpBg
hp.BackgroundColor3 = Color3.fromRGB(255,255,255)
hp.BorderSizePixel = 0
hp.Size = UDim2.new(0, 130, 0, 19)

local grad3 = Instance.new("UIGradient")
grad3.Color = ColorSequence.new(Color3.fromRGB(0,200,140), Color3.fromRGB(120,255,50))
grad3.Rotation = 90
grad3.Parent = hp

local nameLbl = Instance.new("TextLabel")
nameLbl.Parent = bg
nameLbl.BackgroundTransparency = 1
nameLbl.Position = UDim2.new(0.220, 0, 0.070, 0)
nameLbl.Size = UDim2.new(0, 268, 0, 19)
nameLbl.Font = Enum.Font.Code
nameLbl.TextColor3 = Color3.fromRGB(255,255,255)
nameLbl.TextScaled = true
nameLbl.TextStrokeTransparency = 0

RunService.Heartbeat:Connect(function()
    if not Config.TargetAim.TargetStats or not Config.TargetAim.Enabled then
        bg.Visible = false
        return
    end
    local t = Players:FindFirstChild(Config.TargetAim.Target)
    if not t or not t.Character then bg.Visible = false return end
    local hum = t.Character:FindFirstChildOfClass("Humanoid")
    if not hum then bg.Visible = false return end
    bg.Visible = true
    nameLbl.Text = hum.DisplayName .. " [" .. t.Name .. "]"
    pic.Image = "rbxthumb://type=AvatarHeadShot&id=" .. t.UserId .. "&w=420&h=420"
    hp:TweenSize(UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0), "In", "Linear", 0.4)
end)

local function attachHealth(target)
    if healthConns[target] then return end
    local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    healthConns[target] = hum.HealthChanged:Connect(function()
        local hl = target.Character and target.Character:FindFirstChild("LithiumHighlight")
        if hl then
            hl.OutlineColor = Color3.fromRGB(255, 0, 0)
            task.delay(0.5, function()
                if hl and Config.TargetAim.Highlight then
                    hl.OutlineColor = Config.TargetAim.HighlightOutlineColor
                end
            end)
        end
    end)
end

RunService.Heartbeat:Connect(function()
    local target = Players:FindFirstChild(Config.TargetAim.Target)
    for _, p in ipairs(Players:GetPlayers()) do
        local hl = p.Character and p.Character:FindFirstChild("LithiumHighlight")
        if hl and (not target or not Config.TargetAim.Highlight or p ~= target) then
            hl:Destroy()
            if healthConns[p] then healthConns[p]:Disconnect() healthConns[p] = nil end
        end
    end
    if not Config.TargetAim.Highlight or not target or not target.Character then return end
    if not target.Character:FindFirstChild("Humanoid") then return end
    if not target.Character:FindFirstChild("LithiumHighlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "LithiumHighlight"
        hl.FillTransparency = 1
        hl.OutlineColor = Config.TargetAim.HighlightOutlineColor
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = target.Character
        hl.Parent = target.Character
        attachHealth(target)
    end
end)