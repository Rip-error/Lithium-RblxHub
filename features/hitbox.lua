local Hitbox = {}

local Config  = require(script.Parent.Parent.core.config)
local Helpers = require(script.Parent.Parent.core.helpers)

local Players       = Helpers.Players
local LocalPlayer   = Helpers.LocalPlayer
local RunService    = Helpers.RunService

local Tabs = _G.LITHIUM.Tabs
local Group = Tabs.Main:AddRightGroupbox('Hitbox Expander')

local highlights = {}

Group:AddToggle('HitboxEnabled', {
    Text = 'Enabled',
    Default = false,
    Callback = function(v) Config.HitboxExpander.Enabled = v end,
})

Group:AddToggle('HitboxVisualize', {
    Text = 'Visualize',
    Default = false,
    Callback = function(v) Config.HitboxExpander.Visualize = v end,
}):AddColorPicker('HitboxColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Fill Color',
    Callback = function(c) Config.HitboxExpander.Color = c end,
}):AddColorPicker('HitboxOutline', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Outline Color',
    Callback = function(c) Config.HitboxExpander.OutlineColor = c end,
})

Group:AddSlider('HitboxFillTrans', {
    Text = 'Fill Transparency',
    Default = 0.5, Min = 0, Max = 1, Rounding = 2,
    Callback = function(v) Config.HitboxExpander.FillTransparency = v end,
})

Group:AddSlider('HitboxOutlineTrans', {
    Text = 'Outline Transparency',
    Default = 0.3, Min = 0, Max = 1, Rounding = 2,
    Callback = function(v) Config.HitboxExpander.OutlineTransparency = v end,
})

Group:AddSlider('HitboxSize', {
    Text = 'Size',
    Default = 15, Min = 1, Max = 37, Rounding = 0,
    Callback = function(v) Config.HitboxExpander.Size = v end,
})

RunService.RenderStepped:Connect(function()
    if not Config.HitboxExpander.Enabled then return end
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        local HRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not HRP then continue end
        HRP.Size = Vector3.new(Config.HitboxExpander.Size, Config.HitboxExpander.Size, Config.HitboxExpander.Size)
        HRP.CanCollide = false

        if Config.HitboxExpander.Visualize then
            if not highlights[Player] then
                local v = Instance.new("Highlight")
                HRP.Transparency = 0.9
                v.Parent = HRP
                v.FillColor = Config.HitboxExpander.Color
                v.OutlineColor = Config.HitboxExpander.OutlineColor
                v.FillTransparency = Config.HitboxExpander.FillTransparency
                v.OutlineTransparency = Config.HitboxExpander.OutlineTransparency
                highlights[Player] = v
            else
                local v = highlights[Player]
                HRP.Transparency = 0.9
                v.FillColor = Config.HitboxExpander.Color
                v.OutlineColor = Config.HitboxExpander.OutlineColor
                v.FillTransparency = Config.HitboxExpander.FillTransparency
                v.OutlineTransparency = Config.HitboxExpander.OutlineTransparency
            end
        else
            local v = highlights[Player]
            if v then
                v:Destroy()
                HRP.Transparency = 1
                highlights[Player] = nil
            end
        end
    end
end)

return Hitbox