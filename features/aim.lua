local Aim = {}

local Config  = require(script.Parent.Parent.core.config)
local Helpers = require(script.Parent.Parent.core.helpers)
local Tabs    = _G.LITHIUM.Tabs

local Players = Helpers.Players
local LocalPlayer = Helpers.LocalPlayer
local RunService = Helpers.RunService
local UserInputService = Helpers.UserInputService

local TargetAimTab = Tabs.Main:AddLeftTabbox():AddTab('Target aim')
local ChecksTab    = Tabs.Main:AddLeftTabbox():AddTab('Checks')
local OptionsTab   = Tabs.Main:AddLeftTabbox():AddTab('Options')

TargetAimTab:AddToggle('TargetAimEnabled', {
    Text = 'Enabled',
    Default = false,
    Callback = function(v)
        Config.TargetAim.Enabled = v
        if not v then
            Config.TargetAim.Target = "None"
            _G.LITHIUM.TargetAim.tracer.Visible = false
            _G.LITHIUM.TargetAim.tracerOutline.Visible = false
        end
    end,
}):AddKeyPicker('TargetAimKey', {
    Default = 'Q',
    Text = 'Target Aim',
    Mode = 'Toggle',
    Callback = function(v)
        if not Config.TargetAim.Enabled then return end
        if v then
            local t = Helpers.getClosestToCursor({
                fovEnabled = Config.TargetAim.DotCircle,
                checks = Config.Checks,
            })
            Config.TargetAim.Target = t and t.Name or "None"
        else
            Config.TargetAim.Target = "None"
        end
    end,
})

TargetAimTab:AddToggle('AutoSelect', {
    Text = 'Auto Select',
    Default = false,
    Callback = function(v)
        Config.TargetAim.AutoSelect = v
        if v then
            RunService:BindToRenderStep("LithiumAutoSelect", 1, function()
                local t = Helpers.getClosestToCursor({ checks = Config.Checks })
                Config.TargetAim.Target = t and t.Name or "None"
            end)
        else
            RunService:UnbindFromRenderStep("LithiumAutoSelect")
        end
    end,
})

TargetAimTab:AddToggle('AutoFire', {
    Text = 'Auto Fire',
    Default = false,
    Callback = function(v) Config.TargetAim.AutoFire = v end,
})

TargetAimTab:AddToggle('LookAt', {
    Text = 'Look At',
    Default = false,
    Callback = function(v) Config.TargetAim.LookAt = v end,
})

TargetAimTab:AddButton('Teleport to Target', function()
    local name = Config.TargetAim.Target
    if not name or name == "None" then
        Helpers.notify("Lithium", "No target", 3)
        return
    end
    local t = Players:FindFirstChild(name)
    if not t or not t.Character or not t.Character:FindFirstChild("HumanoidRootPart") then
        Helpers.notify("Lithium", "Target not loaded", 3)
        return
    end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Helpers.notify("Lithium", "Your character not loaded", 3)
        return
    end
    hrp.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
end)

TargetAimTab:AddToggle('AutoKillEnabled', {
    Text = 'AutoKill',
    Default = false,
    Callback = function(v) Config.TargetAim.Autokill = v end,
}):AddKeyPicker('AutoKillKey', {
    Default = 'none',
    Text = 'Auto Kill',
    Mode = 'Toggle',
    Callback = function(v) Config.TargetAim.Autokill = v end,
})

TargetAimTab:AddToggle('Spoofer', {
    Text = 'Spoofer',
    Default = false,
    Callback = function(v) Config.TargetAim.Spoofer = v end,
})

TargetAimTab:AddToggle('AutoStomp', {
    Text = 'Auto Stomp',
    Default = false,
    Callback = function(v) Config.TargetAim.AutoStomp = v end,
})

TargetAimTab:AddToggle('ToggleStrafe', {
    Text = 'Strafe',
    Default = false,
    Callback = function(v) Config.TargetAim.ToggleStrafe = v end,
}):AddKeyPicker('StrafeKey', {
    Default = 'Z',
    Text = 'Strafe',
    Mode = 'Toggle',
    Callback = function(v)
        if Config.TargetAim.ToggleStrafe then
            Config.TargetAim.Strafe = v
        end
    end,
})

TargetAimTab:AddDropdown('StrafeMethod', {
    Values = {'Orbit', 'Randomize'},
    Default = 2,
    Multi = false,
    Text = 'Strafe Method',
    Callback = function(v) Config.TargetAim.StrafeMethod = v end,
})

TargetAimTab:AddSlider('StrafePrediction', {
    Text = 'Strafe Prediction',
    Default = 0.1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(v) Config.TargetAim.StrafePrediction = v end,
})

ChecksTab:AddToggle('CheckWall', {
    Text = 'Wall',
    Default = false,
    Callback = function(v) Config.Checks.Wall = v end,
})
ChecksTab:AddToggle('CheckForcefield', {
    Text = 'Forcefield',
    Default = false,
    Callback = function(v) Config.Checks.Forcefield = v end,
})
ChecksTab:AddToggle('CheckAlive', {
    Text = 'Alive',
    Default = false,
    Callback = function(v) Config.Checks.Alive = v end,
})
ChecksTab:AddToggle('CheckTeam', {
    Text = 'Team',
    Default = false,
    Callback = function(v) Config.Checks.Team = v end,
})

OptionsTab:AddInput('PredictionInput', {
    Default = '0.0000',
    Numeric = true,
    Finished = true,
    Text = 'Prediction',
    Placeholder = '0.0000',
    Callback = function(v) Config.TargetAim.Prediction = tonumber(v) or 0 end,
})
OptionsTab:AddToggle('AutoPredictToggle', {
    Text = 'Auto Prediction',
    Default = false,
    Callback = function(v) Config.TargetAim.AutoPredict = v end,
})
OptionsTab:AddDropdown('PredictModeDropdown', {
    Values = {'Calculate', 'Ping Sets'},
    Default = 1,
    Multi = false,
    Text = 'Prediction Mode',
    Callback = function(v) Config.TargetAim.PredictMode = v end,
})
OptionsTab:AddDropdown('HitPartDropdown', {
    Values = {'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso'},
    Default = 'Head',
    Multi = false,
    Text = 'Hit Part',
    Callback = function(v) Config.TargetAim.HitPart = v end,
})
OptionsTab:AddInput('OffsetInput', {
    Default = '0',
    Numeric = true,
    Finished = true,
    Text = 'Y Offset',
    Placeholder = '0',
    Callback = function(v) Config.TargetAim.Offset = tonumber(v) or 0 end,
})
OptionsTab:AddToggle('AirPartToggle', {
    Text = 'Airshot Part',
    Default = false,
    Callback = function(v) Config.TargetAim.AirPartEnabled = v end,
})
OptionsTab:AddDropdown('AirPartDropdown', {
    Values = {'Head', 'HumanoidRootPart', 'UpperTorso', 'LowerTorso'},
    Default = 'Head',
    Multi = false,
    Text = 'Airshot Part',
    Callback = function(v) Config.TargetAim.AirPart = v end,
})
OptionsTab:AddToggle('ResolverToggle', {
    Text = 'Resolver',
    Default = false,
    Callback = function(v) Config.TargetAim.Resolver = v end,
})

return Aim