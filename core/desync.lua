local Desync = {}

local Workspace    = game:GetService("Workspace")
local RunService   = game:GetService("RunService")
local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer
local Camera       = Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local Helpers = require(script.Parent:WaitForChild("helpers"))
local Config  = require(script.Parent:WaitForChild("config"))

local SETBACK_POS = CFrame.new(9999, 9999, 9999)

local function buildClone()
    local ok, clone = pcall(function()
        return game:GetObjects("rbxassetid://8246626421")[1]
    end)
    if not ok or not clone then
        warn("[Lithium] desync rig load failed")
        return nil
    end
    clone.Parent = Workspace
    if clone:FindFirstChild("Humanoid") then clone.Humanoid:Destroy() end
    if clone:FindFirstChild("Head") and clone.Head:FindFirstChild("Face") then
        clone.Head.Face:Destroy()
    end
    for _, v in ipairs(clone:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            v.CanCollide   = false
            v.Transparency = 1
        end
    end
    if clone:FindFirstChild("HumanoidRootPart") then
        clone.HumanoidRootPart.Transparency = 1
        clone.HumanoidRootPart.Velocity     = Vector3.zero
        clone.HumanoidRootPart.CFrame       = SETBACK_POS
    end
    return clone
end

Desync.Clone = buildClone()

Desync.Highlight = Instance.new("Highlight")
Desync.Highlight.Enabled          = false
Desync.Highlight.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
Desync.Highlight.FillColor        = Color3.fromRGB(0, 200, 140)
Desync.Highlight.OutlineColor     = Color3.fromRGB(255, 255, 255)
Desync.Highlight.FillTransparency = 0.3
Desync.Highlight.OutlineTransparency = 0
Desync.Highlight.Adornee = Desync.Clone
Desync.Highlight.Parent  = Desync.Clone

Desync.Light = Instance.new("PointLight")
Desync.Light.Color      = Color3.fromRGB(0, 200, 140)
Desync.Light.Brightness = 4
Desync.Light.Range      = 4
Desync.Light.Parent     = Desync.Clone and Desync.Clone:FindFirstChild("HumanoidRootPart")

Desync.Line = Drawing.new("Line")
Desync.Line.Thickness    = 2
Desync.Line.Color        = Color3.fromRGB(0, 200, 140)
Desync.Line.Visible      = false
Desync.Line.Transparency = 1

Desync.Dot = Drawing.new("Circle")
Desync.Dot.Radius      = 6
Desync.Dot.Thickness   = 1.5
Desync.Dot.NumSides    = 16
Desync.Dot.Color       = Color3.fromRGB(0, 200, 140)
Desync.Dot.Filled      = true
Desync.Dot.Transparency = 1
Desync.Dot.Visible      = false

Desync.Status = Drawing.new("Text")
Desync.Status.Text         = "Desync: false"
Desync.Status.Size         = 16
Desync.Status.Font         = 2
Desync.Status.Color        = Color3.fromRGB(255, 0, 0)
Desync.Status.Outline      = true
Desync.Status.OutlineColor = Color3.fromRGB(0, 0, 0)
Desync.Status.Center       = false
Desync.Status.Visible      = false
Desync.Status.Position     = Vector2.new(100, 100)

local setback = Instance.new("Part")
setback.Name       = "LithiumSetback"
setback.Size       = Vector3.new(2, 2, 1)
setback.CanCollide = false
setback.Anchored   = true
setback.Transparency = 1
setback.Parent     = Workspace
Desync.Setback = setback

function Desync.buildOffset()
    local mode = Config.Desync.Mode
    if mode == "Destroy Cheaters" then
        return Vector3.new(9e9, 1, 1)
    elseif mode == "Underground" then
        return Vector3.new(0, -12, 0)
    elseif mode == "Void Spam" then
        local r = math.random(1, 2)
        if r == 1 then return Vector3.zero end
        return Vector3.new(math.random(10000, 50000), math.random(10000, 50000), math.random(10000, 50000))
    elseif mode == "Void" then
        return Vector3.new(math.random(-444444, 444444), math.random(-444444, 444444), math.random(-44444, 44444))
    elseif mode == "Random" then
        local a = Config.Desync.RandomAmount
        return Vector3.new(math.random(-a, a), math.random(-a / 2, a / 2), math.random(-a, a))
    elseif mode == "Safe Shoot" then
        return Vector3.new(0, -5, 0)
    elseif mode == "Custom" then
        return Vector3.new(Config.Desync.CustomX, Config.Desync.CustomY, Config.Desync.CustomZ)
    end
    return Vector3.zero
end

function Desync.tick()
    if not LocalPlayer.Character then
        Desync.Clone:SetPrimaryPartCFrame(SETBACK_POS)
        Desync.Highlight.Enabled = false
        Desync.Line.Visible = false
        Desync.Dot.Visible = false
        Desync.Status.Visible = false
        return
    end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Desync.Dot.Visible = false
        return
    end

    local old = hrp.CFrame
    local applied = old

    if Config.Desync.Enabled then
        local offset = Desync.buildOffset()
        applied = old + offset
        hrp.CFrame = applied
        if not Config.TargetAim.SpectateTarget then
            Camera.CameraSubject = Desync.Setback
        end
        RunService.RenderStepped:Wait()
        Desync.Setback.CFrame = old * CFrame.new(0, hrp.Size.Y / 2 + 0.5, 0)
        hrp.CFrame = old
    end

    if Config.Desync.Visualize and Config.Desync.Enabled then
        Desync.Clone:SetPrimaryPartCFrame(applied)
        Desync.Highlight.Enabled = true
    else
        Desync.Highlight.Enabled = false
        Desync.Clone:SetPrimaryPartCFrame(SETBACK_POS)
    end

    if Config.Desync.Line and Config.Desync.Enabled then
        local sp, onScreen = Camera:WorldToViewportPoint(applied.Position)
        if onScreen then
            Desync.Line.From = UserInputService:GetMouseLocation()
            Desync.Line.To   = Vector2.new(sp.X, sp.Y)
            Desync.Line.Color = Desync.Highlight.FillColor
            Desync.Line.Visible = true
        else
            Desync.Line.Visible = false
        end
    else
        Desync.Line.Visible = false
    end

    if Config.Desync.Dot and Config.Desync.Enabled then
        local sp, onScreen = Camera:WorldToViewportPoint(applied.Position)
        if onScreen then
            Desync.Dot.Position = Vector2.new(sp.X, sp.Y)
            Desync.Dot.Visible = true
        else
            Desync.Dot.Visible = false
        end
    else
        Desync.Dot.Visible = false
    end

    if Config.Desync.Status then
        Desync.Status.Text = "Desync: " .. (Config.Desync.Enabled and "true" or "false")
        Desync.Status.Color = Config.Desync.Enabled and Color3.fromRGB(0, 200, 140) or Color3.fromRGB(255, 0, 0)
        Desync.Status.Visible = true
    else
        Desync.Status.Visible = false
    end
end

function Desync.resetCamera()
    if LocalPlayer.Character then
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
end

return Desync