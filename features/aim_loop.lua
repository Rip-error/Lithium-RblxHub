local AimLoop = {}

local Config    = require(script.Parent.Parent.core.config)
local Helpers   = require(script.Parent.Parent.core.helpers)
local Remote    = require(script.Parent.Parent.core.remote)

local Players         = Helpers.Players
local LocalPlayer     = Helpers.LocalPlayer
local RunService      = Helpers.RunService
local UserInputService= Helpers.UserInputService
local Camera          = Helpers.Camera

local DotCircle = Drawing.new("Circle")
DotCircle.Visible = false
DotCircle.Filled = true
DotCircle.Radius = 5
DotCircle.Thickness = 1.5
DotCircle.Color = Color3.fromRGB(0, 200, 140)
DotCircle.Transparency = 1

local tracerOutline = Drawing.new("Line")
tracerOutline.Visible = false
tracerOutline.Color = Color3.fromRGB(0, 0, 0)
tracerOutline.Thickness = 4

local tracer = Drawing.new("Line")
tracer.Visible = false
tracer.Color = Color3.fromRGB(0, 200, 140)
tracer.Thickness = 2

_G.LITHIUM.TargetAim = _G.LITHIUM.TargetAim or {}
_G.LITHIUM.TargetAim.tracer = tracer
_G.LITHIUM.TargetAim.tracerOutline = tracerOutline
_G.LITHIUM.TargetAim.DotCircle = DotCircle

local M1Down = false
local previousPositions = {}
local customVelocities = {}
local oldVelPos = {}
local ka_lastHealth = {}

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        M1Down = true
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        M1Down = false
    end
end)

local function pingSeconds()
    local ok, v = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
    return ok and v or 0
end

local function computePrediction(hitPart)
    local pred = Config.TargetAim.Prediction
    if Config.TargetAim.AutoPredict then
        if Config.TargetAim.PredictMode == "Ping Sets" then
            pred = pingSeconds() + 0.035
        elseif Config.TargetAim.PredictMode == "Calculate" then
            pred = (hitPart.Position - Camera.CFrame.Position).Magnitude / 1000 + 0.13
        end
    end
    if Config.TargetAim.Resolver then pred = pred + 0.015 end
    return pred
end

local function computePredictedPos(target, hitPart, dt)
    if Config.TargetAim.Resolver then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local lastPos = oldVelPos[target]
            if lastPos then
                hitPart.Velocity = (hrp.Position - lastPos) / dt
            end
            oldVelPos[target] = hrp.Position
        end
    end
    local pred = computePrediction(hitPart)
    local pos = hitPart.Position + hitPart.Velocity * pred
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if Config.TargetAim.AirPartEnabled and hum then
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
            local airPart = target.Character:FindFirstChild(Config.TargetAim.AirPart)
            if airPart then pos = airPart.Position + airPart.Velocity * pred end
        end
    end
    return pos
end

RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        local useDesync = Config.TargetAim.Strafe
            or Config.TargetAim.AutoStomp
            or Config.TargetAim.Autokill

        if not useDesync then return end

        local target = Players:FindFirstChild(Config.TargetAim.Target)
        if not target or not target.Character then return end
        if not target.Character:FindFirstChild("Head") then return end
        if not target.Character:FindFirstChild("HumanoidRootPart") then return end

        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        local SavedPosition = hrp.CFrame

        if Config.TargetAim.Strafe and not (Config.TargetAim.Autokill) then
            if not target.Character:FindFirstChild("ForceField")
                and not Helpers.isKO(target) then
                local currentPos = target.Character.Head.Position
                local lastPos = previousPositions[target] or currentPos
                local est = (currentPos - lastPos) / dt
                local alpha = 0.5
                customVelocities[target] = (customVelocities[target] or Vector3.zero) * alpha + est * (1 - alpha)
                previousPositions[target] = currentPos

                local strafeOffset
                if Config.TargetAim.StrafeMethod == "Orbit" then
                    strafeOffset = Vector3.new(math.cos(tick()*10)*10, 0, math.sin(tick()*10)*10)
                else
                    strafeOffset = Vector3.new(math.random(-15,15), math.random(-15,15), math.random(-15,15))
                end

                local desyncPos = currentPos + customVelocities[target] * Config.TargetAim.StrafePrediction + strafeOffset
                hrp.CFrame = CFrame.lookAt(desyncPos, currentPos)

                if Config.TargetAim.Spoofer then
                    RunService:BindToRenderStep("LithiumRestoreStrafe", 199, function()
                        hrp.CFrame = SavedPosition
                        RunService:UnbindFromRenderStep("LithiumRestoreStrafe")
                    end)
                end

                local args = {
                    [1] = "ShootGun",
                    [2] = tool and tool.Handle or nil,
                    [3] = tool and tool.Handle.Position or Vector3.zero,
                    [4] = currentPos + customVelocities[target] * Config.TargetAim.StrafePrediction,
                    [5] = target.Character.Head,
                    [6] = Vector3.new(0, 0, 0),
                }
                if Remote.MainEvent then
                    if Config.TargetAim.AutoFire or M1Down then
                        Remote.MainEvent:FireServer(unpack(args))
                    end
                end
            end
        end

        if Config.TargetAim.Autokill and not Helpers.isKO(target) then
            local toolHandle = tool and tool:FindFirstChild("Handle")
            local targetHead = target.Character:FindFirstChild("Head")
            if toolHandle and targetHead then
                if not target.Character:FindFirstChild("ForceField") then
                    hrp.CFrame = CFrame.lookAt(targetHead.Position + Vector3.new(math.random(-15,15), math.random(-15,15), math.random(-15,15)), targetHead.Position)
                    Remote.MainEvent:FireServer("ShootGun", toolHandle, toolHandle.Position, targetHead.Position, targetHead, Vector3.new(0, 1, 0))
                else
                    hrp.CFrame = hrp.CFrame + Vector3.new(math.random(-7777, 7777), math.random(0, 7777), math.random(-7777, 7777))
                    if tool then Remote.MainEvent:FireServer("Reload", tool) end
                end
                if Config.TargetAim.Spoofer then
                    RunService:BindToRenderStep("LithiumRestoreAutoKill", 199, function()
                        hrp.CFrame = SavedPosition
                        RunService:UnbindFromRenderStep("LithiumRestoreAutoKill")
                    end)
                end
            end
        end
    end)
end)

RunService.Heartbeat:Connect(function(dt)
    pcall(function()
        if not Config.TargetAim.Enabled or Config.TargetAim.Target == "None" then
            DotCircle.Visible = false
            tracer.Visible = false
            tracerOutline.Visible = false
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.AutoRotate = true end
            end
            return
        end

        local target = Players:FindFirstChild(Config.TargetAim.Target)
        if not target or not target.Character then return end
        local hitPart = target.Character:FindFirstChild(Config.TargetAim.HitPart)
        if not hitPart then return end

        local predictedPos = computePredictedPos(target, hitPart, dt)

        if Config.TargetAim.DotCircle then
            local sp, onScreen = Camera:WorldToViewportPoint(predictedPos)
            if onScreen then
                DotCircle.Position = Vector2.new(sp.X, sp.Y)
                DotCircle.Visible = true
            else
                DotCircle.Visible = false
            end
        else
            DotCircle.Visible = false
        end

        if Config.TargetAim.LookAt then
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHrp and hum then
                hum.AutoRotate = false
                myHrp.CFrame = CFrame.lookAt(myHrp.Position, Vector3.new(target.Character.HumanoidRootPart.Position.X, myHrp.Position.Y, target.Character.HumanoidRootPart.Position.Z))
            end
        end

        if Config.TargetAim.Tracer then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local headSp, onScreen = Camera:WorldToViewportPoint(predictedPos)
                if onScreen then
                    local origin
                    if Config.TargetAim.TracerPosition == "Tool" then
                        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool and tool:FindFirstChild("Handle") then
                            local hsp = Camera:WorldToViewportPoint(tool.Handle.Position)
                            origin = Vector2.new(hsp.X, hsp.Y)
                        end
                    end
                    origin = origin or UserInputService:GetMouseLocation()
                    tracer.From = origin
                    tracerOutline.From = origin
                    tracer.To = Vector2.new(headSp.X, headSp.Y)
                    tracerOutline.To = Vector2.new(headSp.X, headSp.Y)
                    tracer.Color = Config.TargetAim.TracerFillColor
                    tracerOutline.Color = Config.TargetAim.TracerOutlineColor
                    tracer.Visible = true
                    tracerOutline.Visible = true
                else
                    tracer.Visible = false
                    tracerOutline.Visible = false
                end
            end
        else
            tracer.Visible = false
            tracerOutline.Visible = false
        end
    end)
end)

return AimLoop