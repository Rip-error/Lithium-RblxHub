local DesyncLine = Drawing.new("Line")
DesyncLine.Thickness = 2
DesyncLine.Color = Color3.fromRGB(0, 200, 140)
DesyncLine.Visible = false
DesyncLine.Transparency = 1

local DesyncDot = Drawing.new("Circle")
DesyncDot.Radius = 6
DesyncDot.Thickness = 1.5
DesyncDot.NumSides = 16
DesyncDot.Color = Color3.fromRGB(0, 200, 140)
DesyncDot.Filled = true
DesyncDot.Transparency = 1
DesyncDot.Visible = false

local DesyncStatus = Drawing.new("Text")
DesyncStatus.Text = "Desync: false"
DesyncStatus.Size = 16
DesyncStatus.Font = 2
DesyncStatus.Color = Color3.fromRGB(255, 0, 0)
DesyncStatus.Outline = true
DesyncStatus.OutlineColor = Color3.fromRGB(0, 0, 0)
DesyncStatus.Center = false
DesyncStatus.Visible = false
DesyncStatus.Position = Vector2.new(100, 100)

local setback = Instance.new("Part")
setback.Name = "LithiumSetback"
setback.Size = Vector3.new(2, 2, 1)
setback.CanCollide = false
setback.Anchored = true
setback.Transparency = 1
setback.Parent = Workspace

local function buildOffset()
    local m = Config.Desync.Mode
    if m == "Destroy Cheaters" then return Vector3.new(9e9, 1, 1)
    elseif m == "Underground" then return Vector3.new(0, -12, 0)
    elseif m == "Void Spam" then
        if math.random(1,2) == 1 then return Vector3.zero end
        return Vector3.new(math.random(10000,50000), math.random(10000,50000), math.random(10000,50000))
    elseif m == "Void" then return Vector3.new(math.random(-444444,444444), math.random(-444444,444444), math.random(-44444,44444))
    elseif m == "Random" then
        local a = Config.Desync.RandomAmount
        return Vector3.new(math.random(-a,a), math.random(-a/2,a/2), math.random(-a,a))
    elseif m == "Safe Shoot" then return Vector3.new(0, -5, 0)
    elseif m == "Custom" then return Vector3.new(Config.Desync.CustomX, Config.Desync.CustomY, Config.Desync.CustomZ)
    end
    return Vector3.zero
end

RunService.Heartbeat:Connect(function()
    pcall(function()
        if not LocalPlayer.Character then
            BodyClone:SetPrimaryPartCFrame(CFrame.new(9999, 9999, 9999))
            BodyCloneHighlight.Enabled = false
            DesyncLine.Visible = false DesyncDot.Visible = false DesyncStatus.Visible = false
            return
        end
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then DesyncDot.Visible = false return end

        local old = hrp.CFrame
        local applied = old
        if Config.Desync.Enabled then
            local off = buildOffset()
            applied = old + off
            hrp.CFrame = applied
            if not Config.TargetAim.SpectateTarget then Camera.CameraSubject = setback end
            RunService.RenderStepped:Wait()
            setback.CFrame = old * CFrame.new(0, hrp.Size.Y / 2 + 0.5, 0)
            hrp.CFrame = old
        end

        if Config.Desync.Visualize and Config.Desync.Enabled then
            BodyClone:SetPrimaryPartCFrame(applied)
            BodyCloneHighlight.Enabled = true
        else
            BodyCloneHighlight.Enabled = false
            BodyClone:SetPrimaryPartCFrame(CFrame.new(9999, 9999, 9999))
        end

        if Config.Desync.Line and Config.Desync.Enabled then
            local sp, onScreen = Camera:WorldToViewportPoint(applied.Position)
            if onScreen then
                DesyncLine.From = UserInputService:GetMouseLocation()
                DesyncLine.To = Vector2.new(sp.X, sp.Y)
                DesyncLine.Color = BodyCloneHighlight.FillColor
                DesyncLine.Visible = true
            else
                DesyncLine.Visible = false
            end
        else
            DesyncLine.Visible = false
        end

        if Config.Desync.Dot and Config.Desync.Enabled then
            local sp, onScreen = Camera:WorldToViewportPoint(applied.Position)
            DesyncDot.Position = Vector2.new(sp.X, sp.Y)
            DesyncDot.Visible = onScreen
        else
            DesyncDot.Visible = false
        end

        if Config.Desync.Status then
            DesyncStatus.Text = "Desync: " .. (Config.Desync.Enabled and "true" or "false")
            DesyncStatus.Color = Config.Desync.Enabled and Color3.fromRGB(0, 200, 140) or Color3.fromRGB(255, 0, 0)
            DesyncStatus.Visible = true
        else
            DesyncStatus.Visible = false
        end
    end)
end)

local function resetCamera()
    if LocalPlayer.Character then
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
end

local AntiBox = Tabs.Player:AddRightTabbox()
local DesyncGroup = AntiBox:AddTab('Desync')

DesyncGroup:AddToggle('DesyncEnabled', {
    Text = 'Enabled', Default = false,
    Callback = function(v)
        Config.Desync.Enabled = v
        if not v then resetCamera() end
    end,
}):AddKeyPicker('DesyncKeybind', {
    Default = 'None', NoUI = true, Text = 'Desync Key',
    Callback = function()
        Config.Desync.Enabled = not Config.Desync.Enabled
        if not Config.Desync.Enabled then resetCamera() end
    end,
})
DesyncGroup:AddDropdown('DesyncMode', {
    Values = {"Destroy Cheaters","Underground","Void Spam","Void","Random","Safe Shoot","Custom"},
    Default = 7, Multi = false, Text = 'Desync Mode',
    Callback = function(v) Config.Desync.Mode = v end,
})
DesyncGroup:AddSlider('DesyncCustomX', { Text = 'Custom X', Default = 0, Min = -10000, Max = 10000, Rounding = 0, Callback = function(v) Config.Desync.CustomX = v end })
DesyncGroup:AddSlider('DesyncCustomY', { Text = 'Custom Y', Default = 0, Min = -10000, Max = 10000, Rounding = 0, Callback = function(v) Config.Desync.CustomY = v end })
DesyncGroup:AddSlider('DesyncCustomZ', { Text = 'Custom Z', Default = 0, Min = -10000, Max = 10000, Rounding = 0, Callback = function(v) Config.Desync.CustomZ = v end })
DesyncGroup:AddSlider('DesyncRandomAmount', { Text = 'Random Amount', Default = 20, Min = 1, Max = 10000000, Rounding = 0, Callback = function(v) Config.Desync.RandomAmount = v end })
DesyncGroup:AddToggle('DesyncVisualize', {
    Text = 'Visualize', Default = false,
    Callback = function(v) Config.Desync.Visualize = v end,
}):AddColorPicker('DesyncVizColor', {
    Default = Color3.fromRGB(0, 200, 140), Title = 'Color',
    Callback = function(c)
        BodyCloneHighlight.FillColor = c
        DesyncDot.Color = c
    end,
})
DesyncGroup:AddToggle('DesyncLine',   { Text = 'Line',   Default = false, Callback = function(v) Config.Desync.Line = v end })
DesyncGroup:AddToggle('DesyncStatus', { Text = 'Status', Default = false, Callback = function(v) Config.Desync.Status = v end })
DesyncGroup:AddToggle('DesyncDot',    { Text = 'Dot',    Default = false, Callback = function(v) Config.Desync.Dot = v end })