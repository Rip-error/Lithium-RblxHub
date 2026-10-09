local Helpers = {}

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")
local Camera            = Workspace.CurrentCamera
local LocalPlayer       = Players.LocalPlayer

Helpers.Players          = Players
Helpers.RunService       = RunService
Helpers.UserInputService = UserInputService
Helpers.Workspace        = Workspace
Helpers.Camera           = Camera
Helpers.LocalPlayer      = LocalPlayer

function Helpers.isAlive(plr)
    if not plr or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local be = plr.Character:FindFirstChild("BodyEffects")
    if be then
        local ko = be:FindFirstChild("K.O")
        local grabbed = be:FindFirstChild("GRABBING_CONSTRAINT")
        if (ko and ko.Value) or (grabbed and grabbed.Value) then return false end
    end
    return true
end

function Helpers.isAliveSimple(plr)
    if not plr or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

function Helpers.isKO(plr)
    if not plr or not plr.Character then return false end
    local be = plr.Character:FindFirstChild("BodyEffects")
    if not be then return false end
    local ko = be:FindFirstChild("K.O")
    return ko and ko.Value or false
end

function Helpers.isGrabbed(plr)
    if not plr or not plr.Character then return false end
    local be = plr.Character:FindFirstChild("BodyEffects")
    if not be then return false end
    local g = be:FindFirstChild("GRABBING_CONSTRAINT")
    return g and g.Value or false
end

function Helpers.isHoldingKnife()
    local char = LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return false end
    local n = tool.Name:lower()
    return n:find("knife") or n:find("blade") or n:find("dagger") or n:find("sword")
end

function Helpers.isPlayerVisible(plr, origin)
    if not plr or not plr.Character then return false end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return false end
    origin = origin or Camera.CFrame.Position
    local dir = (head.Position - origin).Unit * (head.Position - origin).Magnitude
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances = {LocalPlayer.Character}
    rp.IgnoreWater = true
    local result = Workspace:Raycast(origin, dir, rp)
    return not result or result.Instance:IsDescendantOf(plr.Character)
end

function Helpers.getClosestToCursor(cfg)
    cfg = cfg or {}
    local fovEnabled = cfg.fovEnabled or false
    local fovSize    = cfg.fovSize or 300
    local checks     = cfg.checks or {}

    local mousePos
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        mousePos = UserInputService:GetMouseLocation()
    end

    local closestDist, closestPlayer = math.huge, nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char or not char:FindFirstChild("Head") or not char:FindFirstChild("HumanoidRootPart") then
            continue
        end
        if checks.Alive and not Helpers.isAlive(player) then continue end
        if checks.Team and player.Team == LocalPlayer.Team then continue end
        if checks.Forcefield and char:FindFirstChildWhichIsA("ForceField") then continue end

        local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
        if not onScreen then continue end
        local screenPos = Vector2.new(headPos.X, headPos.Y)
        local dist = (screenPos - mousePos).Magnitude
        if fovEnabled and dist > fovSize then continue end
        if checks.Wall and not Helpers.isPlayerVisible(player) then continue end

        if dist < closestDist then
            closestDist = dist
            closestPlayer = player
        end
    end
    return closestPlayer
end

function Helpers.getNearestByDistance(range)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closestDist, closestPlayer = math.huge, nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char or not char:FindFirstChild("Head") then continue end
        if char:FindFirstChild("ForceField") then continue end
        local dist = (hrp.Position - char.Head.Position).Magnitude
        if dist <= range and dist < closestDist then
            closestDist = dist
            closestPlayer = player
        end
    end
    return closestPlayer
end

function Helpers.setRigTransparency(rig, t)
    for _, v in ipairs(rig:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then v.Transparency = t end
    end
end

function Helpers.setRigCollision(rig, canCollide)
    for _, v in ipairs(rig:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then v.CanCollide = canCollide end
    end
end

function Helpers.setRigColor(rig, color)
    for _, v in ipairs(rig:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then v.Color = color end
    end
end

function Helpers.makeConnection(name, signal, fn)
    local conn = signal:Connect(fn)
    _G.LITHIUM.Connections[name] = conn
    return conn
end

function Helpers.removeConnection(name)
    local conn = _G.LITHIUM.Connections[name]
    if conn then
        conn:Disconnect()
        _G.LITHIUM.Connections[name] = nil
    end
end

function Helpers.notify(title, msg, duration)
    if _G.LITHIUM and _G.LITHIUM.Library then
        _G.LITHIUM.Library:Notify(title, msg, duration or 3)
    else
        warn("[Lithium] " .. title .. " — " .. tostring(msg))
    end
end

return Helpers