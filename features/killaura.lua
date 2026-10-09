local KillAura = {}

local Config  = require(script.Parent.Parent.core.config)
local Helpers = require(script.Parent.Parent.core.helpers)
local Remote  = require(script.Parent.Parent.core.remote)

local Players         = Helpers.Players
local LocalPlayer     = Helpers.LocalPlayer
local RunService      = Helpers.RunService
local Workspace       = Helpers.Workspace

local Tabs = _G.LITHIUM.Tabs

local ka_tracer = Instance.new("Part")
ka_tracer.Size = Vector3.new(0.2, 0.2, 0.2)
ka_tracer.Material = Enum.Material.Neon
ka_tracer.Color = Color3.fromRGB(0, 200, 140)
ka_tracer.Transparency = 1
ka_tracer.Anchored = true
ka_tracer.CanCollide = false
ka_tracer.Parent = Workspace

local ka_lastHealth = {}

local Group = Tabs.Main:AddRightGroupbox('Kill Aura')

Group:AddToggle('KillAuraEnabled', {
    Text = 'Enabled',
    Default = false,
    Callback = function(v)
        Config.KillAura.Enabled = v
        if not v then
            Config.KillAura.Active = false
            ka_tracer.Transparency = 1
        end
    end,
}):AddKeyPicker('KillAuraKey', {
    Default = 'K',
    Text = 'Kill Aura',
    Mode = 'Toggle',
    Callback = function(v)
        if Config.KillAura.Enabled then
            Config.KillAura.Active = v
        end
    end,
})

Group:AddSlider('KillAuraRange', {
    Text = 'Range',
    Default = 250, Min = 10, Max = 250, Rounding = 0,
    Callback = function(v) Config.KillAura.Range = v end,
})

Group:AddToggle('KillAuraSilent', {
    Text = 'Silent',
    Default = false,
    Callback = function(v) Config.KillAura.Silent = v end,
})

Group:AddToggle('KillAuraVisualize', {
    Text = 'Visualize',
    Default = false,
    Callback = function(v) Config.KillAura.Visualize = v end,
}):AddColorPicker('KAVisColor', {
    Default = Color3.fromRGB(0, 200, 140),
    Title = 'Visualizer Color',
    Callback = function(c) ka_tracer.Color = c end,
})

Group:AddToggle('StompAura', {
    Text = 'Stomp Aura',
    Default = false,
    Callback = function(v) Config.KillAura.StompAura = v end,
})

RunService.Heartbeat:Connect(function()
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if not hrp then return end

        if Config.KillAura.Enabled and Config.KillAura.Active then
            if Tool and Tool:FindFirstChild("Handle") then
                local closest, ka_target = math.huge, nil
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer
                        and not Config.KillAura.Whitelist[player.Name]
                        and player.Character
                        and player.Character:FindFirstChild("Head")
                        and not player.Character:FindFirstChild("GRABBING_CONSTRAINT") then
                        local be = player.Character:FindFirstChild("BodyEffects")
                        if be and be:FindFirstChild("K.O") and not be["K.O"].Value then
                            local dist = (hrp.Position - player.Character.Head.Position).Magnitude
                            if dist < closest and dist <= Config.KillAura.Range then
                                closest = dist
                                ka_target = player
                            end
                        end
                    end
                end

                if ka_target and ka_target.Character and ka_target.Character:FindFirstChild("Head") then
                    hrp.CFrame = CFrame.lookAt(hrp.Position, ka_target.Character.Head.Position)
                    if Config.KillAura.Visualize then
                        ka_tracer.Transparency = 0
                        ka_tracer.Size = Vector3.new(0.2, 0.2, (hrp.Position - ka_target.Character.Head.Position).Magnitude)
                        ka_tracer.CFrame = CFrame.lookAt(hrp.Position, ka_target.Character.Head.Position) * CFrame.new(0, 0, -ka_tracer.Size.Z / 2)
                    else
                        ka_tracer.Transparency = 1
                    end
                    local hum = ka_target.Character:FindFirstChild("Humanoid")
                    if hum then
                        if not ka_lastHealth[ka_target.Name] then
                            ka_lastHealth[ka_target.Name] = hum.Health
                        end
                        if hum.Health < ka_lastHealth[ka_target.Name] then
                            if Config.HitEffects.HitSounds then
                                local s = Instance.new("Sound")
                                s.Parent = hrp
                                s.SoundId = Config.HitEffects.HitSoundID
                                s.Volume = Config.HitEffects.HitSoundVolume
                                s:Play()
                                s.Ended:Connect(function() s:Destroy() end)
                            end
                        end
                        ka_lastHealth[ka_target.Name] = hum.Health
                    end
                    local offset = Config.KillAura.Silent and Vector3.new(0, -12, 0) or Vector3.new(0, 0, 0)
                    if Remote.MainEvent then
                        Remote.MainEvent:FireServer(
                            "ShootGun",
                            Tool:FindFirstChild("Handle"),
                            Tool:FindFirstChild("Handle").CFrame.Position + offset,
                            ka_target.Character.Head.Position + offset,
                            ka_target.Character.Head,
                            Vector3.new(0, 0, -1)
                        )
                    end
                else
                    ka_tracer.Transparency = 1
                end
            else
                ka_tracer.Transparency = 1
            end
        end
    end)
end)

return KillAura