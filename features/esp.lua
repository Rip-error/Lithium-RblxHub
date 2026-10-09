local ESP = {}

local Helpers = require(script.Parent.Parent.core.helpers)

local Players         = Helpers.Players
local LocalPlayer     = Helpers.LocalPlayer
local RunService      = Helpers.RunService
local Camera          = Helpers.Camera
local Workspace       = Helpers.Workspace

local Tabs = _G.LITHIUM.Tabs
local Group = Tabs.Visual:AddLeftGroupbox('ESP')

local state = {
    BoxEnabled       = false,
    BoxColor         = Color3.fromRGB(103, 89, 179),
    BoxGradientOn    = false,
    BoxGradient1     = Color3.fromRGB(103, 89, 179),
    BoxGradient2     = Color3.fromRGB(204, 102, 255),
    BoxFillTrans     = 0.5,
    BoxOutlineOn     = true,
    BoxOutlineColor  = Color3.fromRGB(0, 0, 0),
    NameEnabled      = false,
    DistanceEnabled  = false,
    SkeletonEnabled  = false,
    SkeletonColor    = Color3.fromRGB(103, 89, 179),
    HealthBarEnabled = false,
    HealthTextEnabled= false,
    HealthBarLerp    = 0.15,
    TracerEnabled    = false,
    TracerColor      = Color3.fromRGB(103, 89, 179),
    TracerOrigin     = 'Bottom Screen',
    ChamsEnabled     = false,
    ChamsFillColor   = Color3.fromRGB(103, 89, 179),
    ChamsOutlineColor= Color3.fromRGB(255, 255, 255),
    ChamsFillTrans   = 0.5,
    TeamCheck        = true,
    MaxDistance      = 1000,
}

local cache = {
    Boxes    = {},
    Names    = {},
    Distances= {},
    Skels    = {},
    Bars     = {},
    BarsText = {},
    Tracers  = {},
    Chams    = {},
}

local function destroy(entry)
    for k, obj in pairs(entry) do
        if typeof(obj) == "Instance" then obj:Destroy()
        elseif typeof(obj) == "table" and obj.Remove then obj:Remove() end
    end
end

local function makeBox(player)
    if cache.Boxes[player] then return cache.Boxes[player] end
    local g = Instance.new("BillboardGui")
    g.Name = "LithiumESP_Box"
    g.Adornee = nil
    g.AlwaysOnTop = true
    g.Size = UDim2.new(4, 0, 5, 0)
    g.StudsOffset = Vector3.new(0, 3, 0)
    g.Parent = game.CoreGui

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = state.BoxColor
    fill.BackgroundTransparency = state.BoxFillTrans
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.Parent = g

    local stroke = Instance.new("UIStroke")
    stroke.Color = state.BoxOutlineColor
    stroke.Thickness = 1
    stroke.Enabled = state.BoxOutlineOn
    stroke.Parent = fill

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, state.BoxGradient1),
        ColorSequenceKeypoint.new(0.5, state.BoxGradient2),
        ColorSequenceKeypoint.new(1, state.BoxGradient1),
    })
    gradient.Enabled = state.BoxGradientOn
    gradient.Parent = fill

    cache.Boxes[player] = { Gui = g, Fill = fill, Stroke = stroke, Gradient = gradient }
    return cache.Boxes[player]
end

local function makeName(player)
    if cache.Names[player] then return cache.Names[player] end
    local g = Instance.new("BillboardGui")
    g.Name = "LithiumESP_Name"
    g.AlwaysOnTop = true
    g.Size = UDim2.new(6, 0, 1, 0)
    g.StudsOffset = Vector3.new(0, 4, 0)
    g.Parent = game.CoreGui
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextStrokeTransparency = 0
    lbl.Text = player.Name
    lbl.Parent = g
    cache.Names[player] = { Gui = g, Label = lbl }
    return cache.Names[player]
end

local function makeDistance(player)
    if cache.Distances[player] then return cache.Distances[player] end
    local g = Instance.new("BillboardGui")
    g.Name = "LithiumESP_Distance"
    g.AlwaysOnTop = true
    g.Size = UDim2.new(4, 0, 1, 0)
    g.StudsOffset = Vector3.new(0, 2.5, 0)
    g.Parent = game.CoreGui
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.TextScaled = true
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextStrokeTransparency = 0
    lbl.Parent = g
    cache.Distances[player] = { Gui = g, Label = lbl }
    return cache.Distances[player]
end

local function makeSkeleton(player)
    if cache.Skels[player] then return cache.Skels[player] end
    local lines = {}
    local bones = {
        {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
        {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
        {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
        {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
        {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    }
    for _ = 1, #bones do
        local l = Drawing.new("Line")
        l.Visible = false
        l.Thickness = 1
        l.Color = state.SkeletonColor
        l.Transparency = 1
        table.insert(lines, l)
    end
    cache.Skels[player] = { Lines = lines, Bones = bones }
    return cache.Skels[player]
end

local function makeHealthBar(player)
    if cache.Bars[player] then return cache.Bars[player] end
    local g = Instance.new("BillboardGui")
    g.Name = "LithiumESP_HP"
    g.AlwaysOnTop = true
    g.Size = UDim2.new(4, 0, 5, 0)
    g.StudsOffset = Vector3.new(0, 3, 0)
    g.Parent = game.CoreGui
    local bg = Instance.new("Frame")
    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bg.BorderSizePixel = 0
    bg.Size = UDim2.new(0.05, 0, 1, 0)
    bg.Position = UDim2.new(-0.15, 0, 0, 0)
    bg.Parent = g
    local bar = Instance.new("Frame")
    bar.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    bar.BorderSizePixel = 0
    bar.Size = UDim2.new(1, 0, 1, 0)
    bar.Parent = bg
    cache.Bars[player] = { Gui = g, BG = bg, Bar = bar, Current = 1 }
    return cache.Bars[player]
end

local function makeHealthText(player)
    if cache.BarsText[player] then return cache.BarsText[player] end
    local g = Instance.new("BillboardGui")
    g.Name = "LithiumESP_HPText"
    g.AlwaysOnTop = true
    g.Size = UDim2.new(4, 0, 1, 0)
    g.StudsOffset = Vector3.new(0, 2, 0)
    g.Parent = game.CoreGui
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextStrokeTransparency = 0
    lbl.Text = ""
    lbl.Parent = g
    cache.BarsText[player] = { Gui = g, Label = lbl }
    return cache.BarsText[player]
end

local function makeTracer(player)
    if cache.Tracers[player] then return cache.Tracers[player] end
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = 1
    l.Color = state.TracerColor
    l.Transparency = 1
    cache.Tracers[player] = { Line = l }
    return cache.Tracers[player]
end

local function makeChams(player)
    if cache.Chams[player] then return cache.Chams[player] end
    if not player.Character then return nil end
    local hl = Instance.new("Highlight")
    hl.Name = "LithiumESP_Chams"
    hl.FillColor = state.ChamsFillColor
    hl.OutlineColor = state.ChamsOutlineColor
    hl.FillTransparency = state.ChamsFillTrans
    hl.OutlineTransparency = 0
    hl.Adornee = player.Character
    hl.Parent = player.Character
    cache.Chams[player] = { Highlight = hl }
    return cache.Chams[player]
end

local function destroyFor(player)
    if cache.Boxes[player]     then destroy(cache.Boxes[player])     cache.Boxes[player] = nil end
    if cache.Names[player]     then destroy(cache.Names[player])     cache.Names[player] = nil end
    if cache.Distances[player] then destroy(cache.Distances[player]) cache.Distances[player] = nil end
    if cache.Skels[player] then
        for _, l in ipairs(cache.Skels[player].Lines) do l:Remove() end
        cache.Skels[player] = nil
    end
    if cache.Bars[player]      then destroy(cache.Bars[player])      cache.Bars[player] = nil end
    if cache.BarsText[player]  then destroy(cache.BarsText[player])  cache.BarsText[player] = nil end
    if cache.Tracers[player]   then cache.Tracers[player].Line:Remove() cache.Tracers[player] = nil end
    if cache.Chams[player] and cache.Chams[player].Highlight then cache.Chams[player].Highlight:Destroy() cache.Chams[player] = nil end
end

Players.PlayerRemoving:Connect(function(p) destroyFor(p) end)

local function worldRoot(player)
    return player.Character and (player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("UpperTorso"))
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local root = worldRoot(player)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then
            destroyFor(player)
            continue
        end
        if state.TeamCheck and player.Team == LocalPlayer.Team and player.Team ~= nil then
            destroyFor(player)
            continue
        end
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp and (myHrp.Position - root.Position).Magnitude > state.MaxDistance then
            destroyFor(player)
            continue
        end

        if state.BoxEnabled then
            local box = makeBox(player)
            box.Gui.Adornee = root
            box.Fill.BackgroundColor3 = state.BoxColor
            box.Fill.BackgroundTransparency = state.BoxFillTrans
            box.Stroke.Enabled = state.BoxOutlineOn
            box.Stroke.Color = state.BoxOutlineColor
            box.Gradient.Enabled = state.BoxGradientOn
        elseif cache.Boxes[player] then
            destroy(cache.Boxes[player])
            cache.Boxes[player] = nil
        end

        if state.NameEnabled then
            local n = makeName(player)
            n.Gui.Adornee = root
            n.Label.Text = player.Name
        elseif cache.Names[player] then
            destroy(cache.Names[player])
            cache.Names[player] = nil
        end

        if state.DistanceEnabled and myHrp then
            local d = makeDistance(player)
            d.Gui.Adornee = root
            d.Label.Text = math.floor((myHrp.Position - root.Position).Magnitude) .. "m"
        elseif cache.Distances[player] then
            destroy(cache.Distances[player])
            cache.Distances[player] = nil
        end

        if state.SkeletonEnabled then
            local skel = makeSkeleton(player)
            for i, pair in ipairs(skel.Bones) do
                local a = player.Character:FindFirstChild(pair[1])
                local b = player.Character:FindFirstChild(pair[2])
                local line = skel.Lines[i]
                if a and b then
                    local aSp, aOn = Camera:WorldToViewportPoint(a.Position)
                    local bSp, bOn = Camera:WorldToViewportPoint(b.Position)
                    if aOn and bOn then
                        line.From = Vector2.new(aSp.X, aSp.Y)
                        line.To   = Vector2.new(bSp.X, bSp.Y)
                        line.Color = state.SkeletonColor
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        elseif cache.Skels[player] then
            for _, l in ipairs(cache.Skels[player].Lines) do l:Remove() end
            cache.Skels[player] = nil
        end

        if state.HealthBarEnabled then
            local bar = makeHealthBar(player)
            bar.Gui.Adornee = root
            local target = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            bar.Current = bar.Current + (target - bar.Current) * state.HealthBarLerp
            bar.Bar.Size = UDim2.new(1, 0, bar.Current, 0)
        elseif cache.Bars[player] then
            destroy(cache.Bars[player])
            cache.Bars[player] = nil
        end

        if state.HealthTextEnabled then
            local t = makeHealthText(player)
            t.Gui.Adornee = root
            t.Label.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
        elseif cache.BarsText[player] then
            destroy(cache.BarsText[player])
            cache.BarsText[player] = nil
        end

        if state.TracerEnabled then
            local t = makeTracer(player)
            local head = player.Character:FindFirstChild("Head")
            if head then
                local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local origin
                    if state.TracerOrigin == 'Cursor' then
                        origin = Helpers.UserInputService:GetMouseLocation()
                    elseif state.TracerOrigin == 'Top Screen' then
                        origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    else
                        origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    end
                    t.Line.From = origin
                    t.Line.To = Vector2.new(sp.X, sp.Y)
                    t.Line.Color = state.TracerColor
                    t.Line.Visible = true
                else
                    t.Line.Visible = false
                end
            end
        elseif cache.Tracers[player] then
            cache.Tracers[player].Line:Remove()
            cache.Tracers[player] = nil
        end

        if state.ChamsEnabled then
            local c = makeChams(player)
            if c and c.Highlight then
                c.Highlight.FillColor = state.ChamsFillColor
                c.Highlight.OutlineColor = state.ChamsOutlineColor
                c.Highlight.FillTransparency = state.ChamsFillTrans
            end
        elseif cache.Chams[player] then
            cache.Chams[player].Highlight:Destroy()
            cache.Chams[player] = nil
        end
    end
end)

Group:AddToggle('BoxESPToggle', {
    Text = 'Box ESP',
    Default = false,
    Callback = function(v) state.BoxEnabled = v end,
}):AddColorPicker('BoxColorPicker', {
    Default = state.BoxColor,
    Title = 'Box Color',
    Callback = function(c)
        state.BoxColor = c
        for _, b in pairs(cache.Boxes) do b.Fill.BackgroundColor3 = c end
    end,
})
Group:AddToggle('BoxGradientToggle', {
    Text = 'Box Gradient',
    Default = false,
    Callback = function(v) state.BoxGradientOn = v end,
}):AddColorPicker('BoxGradientColor1', {
    Default = state.BoxGradient1,
    Title = 'Gradient Color 1',
    Callback = function(c) state.BoxGradient1 = c end,
}):AddColorPicker('BoxGradientColor2', {
    Default = state.BoxGradient2,
    Title = 'Gradient Color 2',
    Callback = function(c) state.BoxGradient2 = c end,
})
Group:AddSlider('BoxFillTransparencySlider', {
    Text = 'Box Fill Transparency',
    Default = 0.5, Min = 0, Max = 1, Rounding = 2,
    Callback = function(v) state.BoxFillTrans = v end,
})
Group:AddToggle('BoxOutlineToggle', {
    Text = 'Box Outline',
    Default = true,
    Callback = function(v) state.BoxOutlineOn = v end,
}):AddColorPicker('BoxOutlineColor', {
    Default = state.BoxOutlineColor,
    Title = 'Outline Color',
    Callback = function(c) state.BoxOutlineColor = c end,
})
Group:AddToggle('NameESPToggle', {
    Text = 'Name ESP',
    Default = false,
    Callback = function(v) state.NameEnabled = v end,
})
Group:AddToggle('DistanceESPToggle', {
    Text = 'Distance ESP',
    Default = false,
    Callback = function(v) state.DistanceEnabled = v end,
})
Group:AddToggle('SkeletonESPToggle', {
    Text = 'Skeleton ESP',
    Default = false,
    Callback = function(v) state.SkeletonEnabled = v end,
}):AddColorPicker('SkeletonColorPicker', {
    Default = state.SkeletonColor,
    Title = 'Skeleton Color',
    Callback = function(c) state.SkeletonColor = c end,
})
Group:AddToggle('HealthBarESPToggle', {
    Text = 'Health Bar',
    Default = false,
    Callback = function(v) state.HealthBarEnabled = v end,
})
Group:AddSlider('HealthBarLerpSpeed', {
    Text = 'Health Bar Smoothness',
    Default = 0.15, Min = 0.05, Max = 0.5, Rounding = 2,
    Callback = function(v) state.HealthBarLerp = v end,
})
Group:AddToggle('HealthTextESPToggle', {
    Text = 'Health Text',
    Default = false,
    Callback = function(v) state.HealthTextEnabled = v end,
})
Group:AddToggle('TracerESPToggle', {
    Text = 'Tracer ESP',
    Default = false,
    Callback = function(v) state.TracerEnabled = v end,
}):AddColorPicker('TracerColorPicker', {
    Default = state.TracerColor,
    Title = 'Tracer Color',
    Callback = function(c) state.TracerColor = c end,
})
Group:AddDropdown('TracerOriginDropdown', {
    Text = 'Tracer Origin',
    Default = 'Bottom Screen',
    Values = {'Bottom Screen', 'Cursor', 'Top Screen'},
    Callback = function(v) state.TracerOrigin = v end,
})
Group:AddToggle('ChamsToggle', {
    Text = 'Chams',
    Default = false,
    Callback = function(v) state.ChamsEnabled = v end,
}):AddColorPicker('ChamsColorPicker', {
    Default = state.ChamsFillColor,
    Title = 'Fill Color',
    Callback = function(c) state.ChamsFillColor = c end,
}):AddColorPicker('ChamsOutlineColorPicker', {
    Default = state.ChamsOutlineColor,
    Title = 'Outline Color',
    Callback = function(c) state.ChamsOutlineColor = c end,
})
Group:AddSlider('ChamFillTransparency', {
    Text = 'Chams Transparency',
    Default = 0.5, Min = 0, Max = 1, Rounding = 2,
    Callback = function(v) state.ChamsFillTrans = v end,
})
Group:AddToggle('TeamCheckToggle', {
    Text = 'Team Check',
    Default = true,
    Callback = function(v) state.TeamCheck = v end,
})
Group:AddSlider('ESPDistanceSlider', {
    Text = 'ESP Distance',
    Default = 1000, Min = 100, Max = 1000, Rounding = 0,
    Callback = function(v) state.MaxDistance = v end,
})

return ESP