local Animation = {}

local Helpers = require(script.Parent.Parent.core.helpers)
local LocalPlayer = Helpers.LocalPlayer

local Tabs = _G.LITHIUM.Tabs
local Group = Tabs.Character:AddRightGroupbox('Animation')

local DanceList = {
    ["Baby Queen - Bouncy Twirl"] = "14352343065",
    ["Floss"]                     = "10714340543",
    ["Yungblud Happier Jump"]     = "15609995579",
    ["Godlike"]                   = "10714347256",
    ["Mae Stephens - Dance"]      = "16553163212",
    ["Victory Dance"]             = "15505456446",
    ["Elton John - Heart Skip"]   = "11309255148",
    ["Sturdy Dance - Ice Spice"]  = "17746180844",
    ["Old Town Road Dance"]       = "10714391240",
    ["Sidekicks"]                 = "10370362157",
    ["Baby Dance"]                = "10713983178",
    ["Rampage"]                   = "139658061151500",
    ["Rambunctious"]              = "85916053135662",
    ["Griddy"]                    = "121966805049108",
    ["Orange Justice"]            = "78927657777256",
}

local danceTrack
local dancePlaying = false
local danceSelected = "Baby Queen - Bouncy Twirl"

local function loadDance(name)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if danceTrack then
        danceTrack:Stop()
        danceTrack:Destroy()
        danceTrack = nil
    end
    local animId = DanceList[name]
    if animId then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. animId
        danceTrack = hum:LoadAnimation(anim)
        danceTrack.Priority = Enum.AnimationPriority.Action
        if dancePlaying then
            danceTrack.Looped = true
            danceTrack:Play()
        end
    end
end

local danceNames = {}
for k in pairs(DanceList) do table.insert(danceNames, k) end
table.sort(danceNames)

Group:AddDropdown('DanceSelect', {
    Values = danceNames,
    Default = 1,
    Multi = false,
    Text = 'Dance Animation',
    Searchable = true,
    Callback = function(v)
        danceSelected = v
        loadDance(v)
    end,
})

Group:AddToggle('DanceToggle', {
    Text = 'Play Dance',
    Default = false,
    Callback = function(v)
        dancePlaying = v
        if v and danceTrack then
            danceTrack.Looped = true
            danceTrack:Play()
        elseif danceTrack then
            danceTrack:Stop()
        end
    end,
}):AddKeyPicker('DanceKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Dance Keybind',
})

local animationOptions = {
    Idle1 = "http://www.roblox.com/asset/?id=180435571",
    Idle2 = "http://www.roblox.com/asset/?id=180435792",
    Walk  = "http://www.roblox.com/asset/?id=180426354",
    Run   = "http://www.roblox.com/asset/?id=180426354",
    Jump  = "http://www.roblox.com/asset/?id=125750702",
    Climb = "http://www.roblox.com/asset/?id=180436334",
    Fall  = "http://www.roblox.com/asset/?id=180436148",
}

local animationSets = {
    ["Default"]   = { idle1="180435571", idle2="180435792", walk="180426354", run="180426354", jump="125750702", climb="180436334", fall="180436148" },
    ["Ninja"]     = { idle1="656117400", idle2="656118341", walk="656121766", run="656118852", jump="656117878", climb="656114359", fall="656115606" },
    ["Superhero"] = { idle1="616111295", idle2="616113536", walk="616122287", run="616117076", jump="616115533", climb="616104706", fall="616108001" },
    ["Robot"]     = { idle1="616088211", idle2="616089559", walk="616095330", run="616091570", jump="616090535", climb="616086039", fall="616087089" },
    ["Cartoon"]   = { idle1="742637544", idle2="742638445", walk="742640026", run="742638842", jump="742637942", climb="742636889", fall="742637151" },
    ["Zombie"]    = { idle1="616158929", idle2="616160636", walk="616168032", run="616163682", jump="616161997", climb="616156119", fall="616157476" },
    ["Mage"]      = { idle1="707742142", idle2="707855907", walk="707897309", run="707861613", jump="707853694", climb="707826056", fall="707829716" },
    ["Knight"]    = { idle1="657595757", idle2="657568135", walk="657552124", run="657564596", jump="657560148", climb="657556206", fall="657552124" },
    ["Vampire"]   = { idle1="1083465857", idle2="1083465857", walk="1083465857", run="1083465857", jump="1083465857", climb="1083465857", fall="1083465857" },
    ["Bubbly"]    = { idle1="910004836", idle2="910009958", walk="910034870", run="910025107", jump="910016857", climb="910009958", fall="910009958" },
    ["Elder"]     = { idle1="845386501", idle2="845397899", walk="845403856", run="845386501", jump="845386501", climb="845386501", fall="845386501" },
    ["Toy"]       = { idle1="782841498", idle2="782841498", walk="782841498", run="782841498", jump="782841498", climb="782841498", fall="782841498" },
}

local keepOnDeath = false

local function applyCustomAnimations(character)
    if not character then return end
    local anim = character:FindFirstChild("Animate")
    if not anim then return end
    local clone = anim:Clone()
    clone.idle.Animation1.AnimationId = animationOptions.Idle1
    clone.idle.Animation2.AnimationId = animationOptions.Idle2
    clone.walk.WalkAnim.AnimationId   = animationOptions.Walk
    clone.run.RunAnim.AnimationId     = animationOptions.Run
    clone.jump.JumpAnim.AnimationId   = animationOptions.Jump
    clone.climb.ClimbAnim.AnimationId = animationOptions.Climb
    clone.fall.FallAnim.AnimationId   = animationOptions.Fall
    anim:Destroy()
    clone.Parent = character
end

LocalPlayer.CharacterAdded:Connect(function(c)
    if keepOnDeath then
        task.wait(1.5)
        applyCustomAnimations(c)
    end
end)

local setNameList = {}
for k in pairs(animationSets) do table.insert(setNameList, k) end
table.sort(setNameList)

local function updateAnim(key, id)
    animationOptions[key] = "http://www.roblox.com/asset/?id=" .. id
    if LocalPlayer.Character then applyCustomAnimations(LocalPlayer.Character) end
end

Group:AddDropdown('AnimPack', {
    Values = setNameList,
    Default = 1,
    Multi = false,
    Text = 'Animation Pack',
    Searchable = true,
    Callback = function(name)
        local set = animationSets[name]
        updateAnim("Idle1", set.idle1)
        updateAnim("Idle2", set.idle2)
        updateAnim("Walk", set.walk)
        updateAnim("Run", set.run)
        updateAnim("Jump", set.jump)
        updateAnim("Climb", set.climb)
        updateAnim("Fall", set.fall)
    end,
})

Group:AddToggle('KeepAnimOnDeath', {
    Text = 'Keep On Death',
    Default = false,
    Callback = function(v) keepOnDeath = v end,
})

Group:AddButton('Load Animation Packs', function()
    Helpers.notify("Lithium", "Vendor anim packs to libs/", 5)
end)

return Animation