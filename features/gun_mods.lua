local GunMods = {}

local Config  = require(script.Parent.Parent.core.config)
local Helpers = require(script.Parent.Parent.core.helpers)
local Remote  = require(script.Parent.Parent.core.remote)

local Players         = Helpers.Players
local LocalPlayer     = Helpers.LocalPlayer
local RunService      = Helpers.RunService
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tabs = _G.LITHIUM.Tabs
local Group = Tabs.Main:AddRightGroupbox('Gun Mods')

local EquipAllConnection
local EquipAddedConnection
local lastEquipTime = 0

local function equipAllGuns()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer.Backpack
    if not char or not backpack then return end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
            tool.Parent = char
        end
    end
end

local function setupEquipAll()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer.Backpack
    if not char or not backpack or not Config.GunMods or not Config.GunMods.EquipAllGuns then return end

    equipAllGuns()

    if EquipAllConnection then EquipAllConnection:Disconnect() end
    EquipAllConnection = char.ChildRemoved:Connect(function(child)
        if Config.GunMods.EquipAllGuns and child:IsA("Tool") and child:FindFirstChild("Ammo") and (tick() - lastEquipTime) >= 0.5 then
            lastEquipTime = tick()
            task.spawn(function()
                task.wait(0.1)
                equipAllGuns()
            end)
        end
    end)

    if EquipAddedConnection then EquipAddedConnection:Disconnect() end
    EquipAddedConnection = backpack.ChildAdded:Connect(function(child)
        if Config.GunMods.EquipAllGuns and child:IsA("Tool") and child:FindFirstChild("Ammo") then
            child.Parent = char
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(5)
    if Config.GunMods and Config.GunMods.EquipAllGuns then setupEquipAll() end
end)

Group:AddToggle('EquipAllGunsEnabled', {
    Text = 'Equip All Guns',
    Default = false,
    Callback = function(v)
        if not Config.GunMods then Config.GunMods = {} end
        Config.GunMods.EquipAllGuns = v
        if v then
            setupEquipAll()
        elseif EquipAllConnection then
            EquipAllConnection:Disconnect()
            EquipAllConnection = nil
        end
    end,
}):AddKeyPicker('EquipAllGunsKey', {
    Default = 'none',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Equip All Guns',
})

Group:AddToggle('RapidFireEnabled', {
    Text = 'Rapid Fire',
    Default = false,
    Callback = function(v)
        Config.RapidFire.Enabled = v
        if v then
            for _, inst in ipairs(game:GetDescendants()) do
                if inst.Name == "ShootingCooldown" and inst:IsA("ValueBase") then
                    inst.Value = 0
                end
                if inst.Name == "ToleranceCooldown" and inst:IsA("ValueBase") then
                    inst.Value = 0
                end
            end
        end
    end,
})

RunService.Heartbeat:Connect(function()
    pcall(function()
        if not Config.RapidFire.Enabled then return end
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("GunScript") then
            for _, v in ipairs(getconnections(tool.Activated)) do
                local info = debug.getinfo(v.Function)
                for i = 1, info.nups do
                    local c = debug.getupvalue(v.Function, i)
                    if type(c) == "number" then
                        debug.setupvalue(v.Function, i, 0)
                    end
                end
            end
        end
    end)
end)

Group:AddToggle('WallbangEnabled', {
    Text = 'Wallbang',
    Default = false,
    Callback = function(v)
        Config.Wallbang.Enabled = v
        if getnamecallmethod then
            local handler = ReplicatedStorage:FindFirstChild("MainModule")
            if not handler then
                Helpers.notify("Lithium", "MainModule not found", 3)
                return
            end
            local module = require(handler)
            if v and Workspace:FindFirstChild("Vehicles") then
                module.Ignored = {Workspace:WaitForChild("Vehicles"), Workspace:WaitForChild("MAP"), Workspace:WaitForChild("Ignored")}
            else
                if Workspace:FindFirstChild("Vehicles") then
                    module.Ignored = {Workspace:WaitForChild("Vehicles"), Workspace:WaitForChild("Ignored")}
                end
            end
        else
            Helpers.notify("Lithium", "Executor does not support this feature", 3)
        end
    end,
})

local removeShootAnims = false
local shootAnimIds = {
    ["rbxassetid://2807049953"] = true,
    ["rbxassetid://2809413000"] = true,
    ["rbxassetid://2809419094"] = true,
    ["rbxassetid://507768375"]  = true,
    ["rbxassetid://507755388"]  = true,
    ["rbxassetid://2877910736"] = true,
}

local function stopShootAnims(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        if track.Animation and shootAnimIds[track.Animation.AnimationId] then
            track:Stop()
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not removeShootAnims then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then stopShootAnims(p.Character) end
    end
end)

Group:AddToggle('AntiflingToggle', {
    Text = 'Remove Shoot Animations',
    Default = false,
    Callback = function(v) removeShootAnims = v end,
})

return GunMods