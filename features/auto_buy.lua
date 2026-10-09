local AutoBuy = {}

local Config  = require(script.Parent.Parent.core.config)
local Helpers = require(script.Parent.Parent.core.helpers)
local Remote  = require(script.Parent.Parent.core.remote)

local Players      = Helpers.Players
local LocalPlayer  = Helpers.LocalPlayer
local RunService   = Helpers.RunService
local Workspace    = Helpers.Workspace

local Tabs = _G.LITHIUM.Tabs
local Group = Tabs.Misc:AddLeftGroupbox('AutoBuy')

local ShopTable = {
    ["[Rifle]"]                     = "[Rifle] - $1694",
    ["[Rifle Ammo]"]                = "5 [Rifle Ammo] - $273",
    ["[LMG]"]                       = "[LMG] - $4098",
    ["[LMG Ammo]"]                  = "200 [LMG Ammo] - $328",
    ["[AK47]"]                      = "[AK47] - $2459",
    ["[AK47 Ammo]"]                 = "90 [AK47 Ammo] - $87",
    ["[AUG]"]                       = "[AUG] - $2131",
    ["[AUG Ammo]"]                  = "90 [AUG Ammo] - $87",
    ["[AR]"]                        = "[AR] - $1093",
    ["[AR Ammo]"]                   = "60 [AR Ammo] - $82",
    ["[Double-Barrel SG]"]          = "[Double-Barrel SG] - $1475",
    ["[Double-Barrel SG Ammo]"]     = "18 [Double-Barrel SG Ammo] - $55",
    ["[Drum-Shotgun]"]              = "[Drum-Shotgun] - $1202",
    ["[Drum-Shotgun Ammo]"]         = "18 [Drum-Shotgun Ammo] - $71",
    ["[DrumGun]"]                   = "[DrumGun] - $3278",
    ["[DrumGun Ammo]"]              = "100 [DrumGun Ammo] - $219",
    ["[Glock]"]                     = "[Glock] - $546",
    ["[Glock Ammo]"]                = "25 [Glock Ammo] - $66",
    ["[P90]"]                       = "[P90] - $1093",
    ["[P90 Ammo]"]                  = "120 [P90 Ammo] - $66",
    ["[RPG]"]                       = "[RPG] - $21855",
    ["[RPG Ammo]"]                  = "5 [RPG Ammo] - $1093",
    ["[Revolver]"]                  = "[Revolver] - $1421",
    ["[Revolver Ammo]"]             = "12 [Revolver Ammo] - $82",
    ["[Silencer]"]                  = "[Silencer] - $601",
    ["[Silencer Ammo]"]             = "25 [Silencer Ammo] - $55",
    ["[SilencerAR]"]                = "[SilencerAR] - $1366",
    ["[SilencerAR Ammo]"]           = "120 [SilencerAR Ammo] - $82",
    ["[Shotgun]"]                   = "[Shotgun] - $1366",
    ["[Shotgun Ammo]"]              = "20 [Shotgun Ammo] - $66",
    ["[SMG]"]                       = "[SMG] - $820",
    ["[SMG Ammo]"]                  = "80 [SMG Ammo] - $66",
    ["[TacticalShotgun]"]           = "[TacticalShotgun] - $1912",
    ["[TacticalShotgun Ammo]"]      = "20 [TacticalShotgun Ammo] - $66",
    ["[Taser]"]                     = "[Taser] - $1093",
}

local GUNS = {'[Rifle]','[LMG]','[AK47]','[AUG]','[AR]','[Double-Barrel SG]','[Drum-Shotgun]','[DrumGun]','[Glock]','[P90]','[RPG]','[Revolver]','[Silencer]','[SilencerAR]','[Shotgun]','[SMG]','[TacticalShotgun]','[Taser]'}
local MASKS = {"paint","ninja","surgeon","riot","hockey","breathing","skull","pumpkin"}
local MASK_SHOP = {
    paint     = "[Paintball Mask] - $66",
    ninja     = "[Ninja Mask] - $66",
    surgeon   = "[Surgeon Mask] - $27",
    riot      = "[Riot Mask] - $66",
    hockey    = "[Hockey Mask] - $66",
    breathing = "[Breathing Mask] - $66",
    skull     = "[Skull Mask] - $66",
    pumpkin   = "[Pumpkin Mask] - $66",
}

local state = {
    BuyingSingle   = false,
    BuyingAmmo     = false,
    AutoHeal       = false,
    AutoArmor      = false,
    AutoMask       = false,
    AutoLoadout    = false,
    AutoLoadoutGun = "[Rifle]",
    HealThreshold  = 99,
    ArmorThreshold = 50,
    MaskSelected   = "surgeon",
}

local function getInventoryAmmo(gunName)
    local inv = LocalPlayer:FindFirstChild("DataFolder")
        and LocalPlayer.DataFolder:FindFirstChild("Inventory")
    if not inv then return 0 end
    local ammo = inv:FindFirstChild(gunName)
    return ammo and tonumber(ammo.Value) or 0
end

local function fireCD(shop)
    if shop and shop:FindFirstChildOfClass("ClickDetector") then
        fireclickdetector(shop:FindFirstChildOfClass("ClickDetector"))
    end
end

local function withTeleport(hrp, saved, bindName, fn)
    hrp.CFrame = saved
    RunService:BindToRenderStep(bindName, 199, function()
        hrp.CFrame = saved
        RunService:UnbindFromRenderStep(bindName)
    end)
    fn()
end

Group:AddDropdown('SelectedGun', {
    Values = GUNS,
    Default = '[Rifle]',
    Multi = false,
    Text = 'Select Gun',
    Callback = function(v) Config.AutoBuy.SelectedGun = v end,
})

Group:AddButton('Buy Selected Gun', function() state.BuyingSingle = true end)

Group:AddToggle('AutoBuyGunAmmo', {
    Text = 'Autobuy Gun + Ammo',
    Default = false,
    Callback = function(v) state.AutoLoadout = v end,
})

Group:AddDropdown('AutoLoadoutGun', {
    Values = GUNS,
    Default = '[Rifle]',
    Multi = false,
    Text = 'Auto Gun',
    Callback = function(v) state.AutoLoadoutGun = v end,
})

Group:AddToggle('AutoHeal', {
    Text = 'Auto Heal',
    Default = false,
    Callback = function(v) state.AutoHeal = v end,
})
Group:AddSlider('AutoHealThreshold', {
    Text = 'Heal Threshold',
    Default = 99, Min = 1, Max = 99, Rounding = 0,
    Callback = function(v) state.HealThreshold = v end,
})

Group:AddToggle('AutoArmor', {
    Text = 'Auto Armor',
    Default = false,
    Callback = function(v) state.AutoArmor = v end,
})
Group:AddSlider('AutoArmorThreshold', {
    Text = 'Armor Threshold',
    Default = 50, Min = 0, Max = 129, Rounding = 0,
    Callback = function(v) state.ArmorThreshold = v end,
})

Group:AddToggle('AutoMask', {
    Text = 'Auto Mask',
    Default = false,
    Callback = function(v) state.AutoMask = v end,
})
Group:AddDropdown('MaskSelection', {
    Values = MASKS,
    Default = "surgeon",
    Multi = false,
    Text = 'Select Mask',
    Callback = function(v) state.MaskSelected = v end,
})

-- Main auto-buy driver
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local shop = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Shop")
        if not shop then return end

        -- Buy single
        if state.BuyingSingle
            and not char:FindFirstChild(Config.AutoBuy.SelectedGun)
            and not LocalPlayer.Backpack:FindFirstChild(Config.AutoBuy.SelectedGun) then
            local data = ShopTable[Config.AutoBuy.SelectedGun]
            if data then
                local s = shop:FindFirstChild(data)
                if s and s:FindFirstChild("Head") then
                    local saved = hrp.CFrame
                    withTeleport(hrp, s.Head.CFrame, "LithiumRestoreSingle", function()
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then tool.Parent = LocalPlayer.Backpack end
                        fireCD(s)
                    end)
                end
            end
        else
            state.BuyingSingle = false
        end

        -- Auto loadout (gun)
        if state.AutoLoadout then
            local gunName = state.AutoLoadoutGun
            local hasGun = char:FindFirstChild(gunName) or LocalPlayer.Backpack:FindFirstChild(gunName)
            if not hasGun and ShopTable[gunName] then
                local s = shop:FindFirstChild(ShopTable[gunName])
                if s and s:FindFirstChild("Head") then
                    local saved = hrp.CFrame
                    withTeleport(hrp, s.Head.CFrame, "LithiumRestoreAutoGun", function()
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then tool.Parent = LocalPlayer.Backpack end
                        fireCD(s)
                    end)
                end
            end
        end

        -- Auto heal (Taco)
        if state.AutoHeal then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and hum.Health <= state.HealThreshold then
                local shopName = "[Taco] - $4"
                local s = shop:FindFirstChild(shopName)
                if s and s:FindFirstChild("Head") then
                    local saved = hrp.CFrame
                    hrp.CFrame = s.Head.CFrame * CFrame.new(0, -3.1, 0)
                    RunService:BindToRenderStep("LithiumRestoreHeal", 199, function()
                        hrp.CFrame = saved
                        RunService:UnbindFromRenderStep("LithiumRestoreHeal")
                    end)
                    local backpackTaco = LocalPlayer.Backpack:FindFirstChild("[Taco]")
                    local charTaco = char:FindFirstChild("[Taco]")
                    if backpackTaco then
                        backpackTaco.Parent = char
                    elseif charTaco then
                        charTaco:Activate()
                    else
                        fireCD(s)
                    end
                end
            end
        end

        -- Auto armor
        if state.AutoArmor then
            local be = char:FindFirstChild("BodyEffects")
            local armor = be and be:FindFirstChild("Armor")
            if armor and armor.Value <= state.ArmorThreshold then
                local shopName = "[High-Medium Armor] - $2513"
                local s = shop:FindFirstChild(shopName)
                if s and s:FindFirstChild("Head") then
                    local saved = hrp.CFrame
                    hrp.CFrame = s.Head.CFrame * CFrame.new(0, -1.8, 0)
                    RunService:BindToRenderStep("LithiumRestoreArmor", 199, function()
                        hrp.CFrame = saved
                        RunService:UnbindFromRenderStep("LithiumRestoreArmor")
                    end)
                    local tool = char:FindFirstChildWhichIsA("Tool")
                    if tool then tool.Parent = LocalPlayer.Backpack end
                    fireCD(s)
                end
            end
        end

        -- Auto mask
        if state.AutoMask then
            local maskShopName = MASK_SHOP[state.MaskSelected]
            local s = shop:FindFirstChild(maskShopName)
            if s and s:FindFirstChild("Head") then
                local hasMask = char:FindFirstChild("In-gameMask")
                local bpMask = LocalPlayer.Backpack:FindFirstChild("[Mask]")
                local charMask = char:FindFirstChild("[Mask]")
                if hasMask then
                    state.AutoMask = false
                elseif bpMask or charMask then
                    if bpMask then bpMask.Parent = char end
                    local mt = char:FindFirstChild("[Mask]")
                    if mt then
                        mt:Activate()
                        task.wait(1)
                        if mt.Parent then mt.Parent = LocalPlayer.Backpack end
                    end
                    state.AutoMask = false
                else
                    local saved = hrp.CFrame
                    withTeleport(hrp, s.Head.CFrame * CFrame.new(0, 2, 0), "LithiumRestoreMask", function() fireCD(s) end)
                end
            end
        end
    end)
end)

return AutoBuy