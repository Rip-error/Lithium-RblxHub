local World = {}

local Helpers = require(script.Parent.Parent.core.helpers)
local LocalPlayer = Helpers.LocalPlayer

local Tabs = _G.LITHIUM.Tabs
local Group = Tabs.Visual:AddRightGroupbox('World')

local Lighting = game:GetService("Lighting")

local original = {
    Ambient                    = Lighting.Ambient,
    OutdoorAmbient             = Lighting.OutdoorAmbient,
    FogColor                   = Lighting.FogColor,
    FogStart                   = Lighting.FogStart,
    FogEnd                     = Lighting.FogEnd,
    Brightness                 = Lighting.Brightness,
    ClockTime                  = Lighting.ClockTime,
    GlobalShadows              = Lighting.GlobalShadows,
    EnvironmentDiffuseScale    = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale   = Lighting.EnvironmentSpecularScale,
    ExposureCompensation       = Lighting.ExposureCompensation,
    ColorShift_Bottom          = Lighting.ColorShift_Bottom,
    ColorShift_Top             = Lighting.ColorShift_Top,
    GeographicLatitude         = Lighting.GeographicLatitude,
}

local defaultSky = Lighting:FindFirstChildOfClass("Sky")
local defaultSkybox = defaultSky and {
    Bk = defaultSky.SkyboxBk, Dn = defaultSky.SkyboxDn, Ft = defaultSky.SkyboxFt,
    Lf = defaultSky.SkyboxLf, Rt = defaultSky.SkyboxRt, Up = defaultSky.SkyboxUp,
} or nil

Group:AddButton("Christmas", function()
    local Christmas = game:GetService("ReplicatedStorage"):FindFirstChild("Christmas_2024")
    if Christmas then
        local snow = Christmas:FindFirstChild("SnowProps")
        if snow then snow:Clone().Parent = workspace end
    end
end)

Group:AddToggle('CustomAmbient', {
    Text = 'Custom Ambient',
    Default = false,
    Callback = function(v) if v then Lighting.Ambient = ambientColor else Lighting.Ambient = original.Ambient end end,
}):AddColorPicker('AmbientColor', {
    Default = original.Ambient,
    Title = 'Ambient Color',
    Callback = function(c) ambientColor = c if _G.LITHIUM.Toggles and _G.LITHIUM.Toggles.CustomAmbient and _G.LITHIUM.Toggles.CustomAmbient.Value then Lighting.Ambient = c end end,
})

local ambientColor = original.Ambient

Group:AddToggle('CustomFog', {
    Text = 'Custom Fog',
    Default = false,
    Callback = function(v)
        if v then
            Lighting.FogColor = fogColor
            Lighting.FogStart = fogStart
            Lighting.FogEnd = fogEnd
        else
            Lighting.FogColor = original.FogColor
            Lighting.FogStart = original.FogStart
            Lighting.FogEnd = original.FogEnd
        end
    end,
}):AddColorPicker('FogColor', {
    Default = original.FogColor,
    Title = 'Fog Color',
    Callback = function(c) fogColor = c end,
})
Group:AddSlider('FogStart', {
    Text = 'Fog Start',
    Default = original.FogStart, Min = 0, Max = 1000, Rounding = 1,
    Callback = function(v) fogStart = v end,
})
Group:AddSlider('FogEnd', {
    Text = 'Fog End',
    Default = original.FogEnd, Min = 0, Max = 1000, Rounding = 1,
    Callback = function(v) fogEnd = v end,
})

Group:AddToggle('CustomBrightness', {
    Text = 'Custom Brightness',
    Default = false,
    Callback = function(v) Lighting.Brightness = v and brightVal or original.Brightness end,
})
Group:AddSlider('BrightnessValue', {
    Text = 'Brightness',
    Default = original.Brightness, Min = 0, Max = 10, Rounding = 1,
    Callback = function(v) brightVal = v end,
})

Group:AddToggle('CustomClockTime', {
    Text = 'Custom Clock Time',
    Default = false,
    Callback = function(v) Lighting.ClockTime = v and clockVal or original.ClockTime end,
})
Group:AddSlider('ClockTimeValue', {
    Text = 'Clock Time',
    Default = original.ClockTime, Min = 0, Max = 24, Rounding = 1,
    Callback = function(v) clockVal = v end,
})

Group:AddToggle('GlobalShadows', {
    Text = 'Global Shadows',
    Default = original.GlobalShadows,
    Callback = function(v) Lighting.GlobalShadows = v end,
})

Group:AddToggle('CustomEnvironmentDiffuse', {
    Text = 'Custom Environment Diffuse',
    Default = false,
    Callback = function(v) Lighting.EnvironmentDiffuseScale = v and envDiffVal or original.EnvironmentDiffuseScale end,
})
Group:AddSlider('EnvironmentDiffuseValue', {
    Text = 'Environment Diffuse Scale',
    Default = original.EnvironmentDiffuseScale, Min = 0, Max = 1, Rounding = 2,
    Callback = function(v) envDiffVal = v end,
})

Group:AddToggle('CustomExposure', {
    Text = 'Custom Exposure',
    Default = false,
    Callback = function(v) Lighting.ExposureCompensation = v and exposureVal or original.ExposureCompensation end,
})
Group:AddSlider('ExposureValue', {
    Text = 'Exposure',
    Default = original.ExposureCompensation, Min = -3, Max = 3, Rounding = 1,
    Callback = function(v) exposureVal = v end,
})

Group:AddToggle('CustomGeographicLatitude', {
    Text = 'Custom Geographic Latitude',
    Default = false,
    Callback = function(v) Lighting.GeographicLatitude = v and latVal or original.GeographicLatitude end,
})
Group:AddSlider('GeographicLatitudeValue', {
    Text = 'Geographic Latitude',
    Default = original.GeographicLatitude, Min = -90, Max = 90, Rounding = 1,
    Callback = function(v) latVal = v end,
})

-- Nebula Theme
local nebulaColor = Color3.fromRGB(173, 216, 230)
Group:AddToggle('NebulaTheme', {
    Text = 'Nebula Theme',
    Default = false,
    Callback = function(v)
        if v then
            local b = Instance.new("BloomEffect", Lighting)
            b.Intensity = 0.7
            b.Size = 24
            b.Threshold = 1
            b.Name = "LithiumBloom"

            local c = Instance.new("ColorCorrectionEffect", Lighting)
            c.Saturation = 0.5
            c.Contrast = 0.2
            c.TintColor = nebulaColor
            c.Name = "LithiumColorCorrection"

            local a = Instance.new("Atmosphere", Lighting)
            a.Density = 0.4
            a.Offset = 0.25
            a.Glare = 1
            a.Haze = 2
            a.Color = nebulaColor
            a.Decay = nebulaColor
            a.Name = "LithiumAtmosphere"

            Lighting.Ambient = nebulaColor
            Lighting.OutdoorAmbient = nebulaColor
            Lighting.FogColor = nebulaColor
            Lighting.FogStart = 100
            Lighting.FogEnd = 500
        else
            for _, n in ipairs({"LithiumBloom", "LithiumColorCorrection", "LithiumAtmosphere"}) do
                local o = Lighting:FindFirstChild(n)
                if o then o:Destroy() end
            end
            Lighting.Ambient = original.Ambient
            Lighting.OutdoorAmbient = original.OutdoorAmbient
            Lighting.FogColor = original.FogColor
            Lighting.FogStart = original.FogStart
            Lighting.FogEnd = original.FogEnd
        end
    end,
}):AddColorPicker('NebulaColor', {
    Default = nebulaColor,
    Title = 'Nebula Color',
    Callback = function(c)
        nebulaColor = c
        local nc = Lighting:FindFirstChild("LithiumColorCorrection")
        if nc then nc.TintColor = c end
        local na = Lighting:FindFirstChild("LithiumAtmosphere")
        if na then na.Color = c na.Decay = c end
    end,
})

-- Skybox
local skyAssets = {
    ["Black Storm"] = {Bk="rbxassetid://15502511288", Dn="rbxassetid://15502508460", Ft="rbxassetid://15502510289", Lf="rbxassetid://15502507918", Rt="rbxassetid://15502509398", Up="rbxassetid://15502511911"},
    ["HD"]          = {Bk="rbxassetid://16553658937", Dn="rbxassetid://16553660713", Ft="rbxassetid://16553662144", Lf="rbxassetid://16553664042", Rt="rbxassetid://16553665766", Up="rbxassetid://16553667750"},
    ["Snow"]        = {Bk="rbxassetid://155657655",   Dn="rbxassetid://155674246",   Ft="rbxassetid://155657609",   Lf="rbxassetid://155657671",   Rt="rbxassetid://155657619",   Up="rbxassetid://155674931"},
    ["Blue Space"]  = {Bk="rbxassetid://15536110634", Dn="rbxassetid://15536112543", Ft="rbxassetid://15536116141", Lf="rbxassetid://15536114370", Rt="rbxassetid://15536118762", Up="rbxassetid://15536117282"},
    ["Realistic"]   = {Bk="rbxassetid://653719502",   Dn="rbxassetid://653718790",   Ft="rbxassetid://653719067",   Lf="rbxassetid://653719190",   Rt="rbxassetid://653718931",   Up="rbxassetid://653719321"},
    ["Stormy"]      = {Bk="rbxassetid://18703245834", Dn="rbxassetid://18703243349", Ft="rbxassetid://18703240532", Lf="rbxassetid://18703237556", Rt="rbxassetid://18703235430", Up="rbxassetid://18703232671"},
    ["Pink"]        = {Bk="rbxassetid://12216109205", Dn="rbxassetid://12216109875", Ft="rbxassetid://12216109489", Lf="rbxassetid://12216110170", Rt="rbxassetid://12216110471", Up="rbxassetid://12216108877"},
    ["Sunset"]      = {Bk="rbxassetid://600830446",   Dn="rbxassetid://600831635",   Ft="rbxassetid://600832720",   Lf="rbxassetid://600886090",   Rt="rbxassetid://600833862",   Up="rbxassetid://600835177"},
    ["Arctic"]      = {Bk="rbxassetid://225469390",   Dn="rbxassetid://225469395",   Ft="rbxassetid://225469403",   Lf="rbxassetid://225469450",   Rt="rbxassetid://225469471",   Up="rbxassetid://225469481"},
    ["Space"]       = {Bk="rbxassetid://166509999",   Dn="rbxassetid://166510057",   Ft="rbxassetid://166510116",   Lf="rbxassetid://166510092",   Rt="rbxassetid://166510131",   Up="rbxassetid://166510114"},
    ["Roblox Default"] = {Bk="rbxasset://textures/sky/sky512_bk.tex", Dn="rbxasset://textures/sky/sky512_dn.tex", Ft="rbxasset://textures/sky/sky512_ft.tex", Lf="rbxasset://textures/sky/sky512_lf.tex", Rt="rbxasset://textures/sky/sky512_rt.tex", Up="rbxasset://textures/sky/sky512_up.tex"},
    ["Red Night"]   = {Bk="rbxassetid://401664839",   Dn="rbxassetid://401664862",   Ft="rbxassetid://401664960",   Lf="rbxassetid://401664881",   Rt="rbxassetid://401664901",   Up="rbxassetid://401664936"},
    ["Deep Space 1"]= {Bk="rbxassetid://149397692",   Dn="rbxassetid://149397686",   Ft="rbxassetid://149397697",   Lf="rbxassetid://149397684",   Rt="rbxassetid://149397688",   Up="rbxassetid://149397702"},
    ["Pink Skies"]  = {Bk="rbxassetid://151165214",   Dn="rbxassetid://151165197",   Ft="rbxassetid://151165224",   Lf="rbxassetid://151165191",   Rt="rbxassetid://151165206",   Up="rbxassetid://151165227"},
    ["Purple Sunset"]={Bk="rbxassetid://264908339",   Dn="rbxassetid://264907909",   Ft="rbxassetid://264909420",   Lf="rbxassetid://264909758",   Rt="rbxassetid://264908886",   Up="rbxassetid://264907379"},
    ["Blue Night"]  = {Bk="rbxassetid://12064107",    Dn="rbxassetid://12064152",    Ft="rbxassetid://12064121",    Lf="rbxassetid://12063984",    Rt="rbxassetid://12064115",    Up="rbxassetid://12064131"},
    ["Blossom Daylight"]={Bk="rbxassetid://271042516",Dn="rbxassetid://271077243",  Ft="rbxassetid://271042556",   Lf="rbxassetid://271042310",   Rt="rbxassetid://271042467",   Up="rbxassetid://271077958"},
    ["Blue Nebula"] = {Bk="rbxassetid://135207744",   Dn="rbxassetid://135207662",   Ft="rbxassetid://135207770",   Lf="rbxassetid://135207615",   Rt="rbxassetid://135207695",   Up="rbxassetid://135207794"},
    ["Blue Planet"] = {Bk="rbxassetid://218955819",   Dn="rbxassetid://218953419",   Ft="rbxassetid://218954524",   Lf="rbxassetid://218958493",   Rt="rbxassetid://218957134",   Up="rbxassetid://218950090"},
    ["Deep Space 2"]= {Bk="rbxassetid://159248188",   Dn="rbxassetid://159248183",   Ft="rbxassetid://159248187",   Lf="rbxassetid://159248173",   Rt="rbxassetid://159248192",   Up="rbxassetid://159248176"},
    ["Summer"]      = {Bk="rbxassetid://16648590964", Dn="rbxassetid://16648617436", Ft="rbxassetid://16648595424", Lf="rbxassetid://16648566370", Rt="rbxassetid://16648577071", Up="rbxassetid://16648598180"},
    ["Galaxy"]      = {Bk="rbxassetid://15983968922", Dn="rbxassetid://15983966825", Ft="rbxassetid://15983965025", Lf="rbxassetid://15983967420", Rt="rbxassetid://15983966246", Up="rbxassetid://15983964246"},
    ["Stylized"]    = {Bk="rbxassetid://18351376859", Dn="rbxassetid://18351374919", Ft="rbxassetid://18351376800", Lf="rbxassetid://18351376469", Rt="rbxassetid://18351376457", Up="rbxassetid://18351377189"},
    ["Minecraft"]   = {Bk="rbxassetid://8735166756",  Dn="rbxassetid://8735166707",  Ft="rbxassetid://8735231668",  Lf="rbxassetid://8735166755",  Rt="rbxassetid://8735166751",  Up="rbxassetid://8735166729"},
    ["Cloudy Rain"] = {Bk="rbxassetid://4498828382",  Dn="rbxassetid://4498828812",  Ft="rbxassetid://4498829917",  Lf="rbxassetid://4498830911",  Rt="rbxassetid://4498830417",  Up="rbxassetid://4498831746"},
    ["Black Cloudy Rain"]={Bk="rbxassetid://149679669",Dn="rbxassetid://149681979",  Ft="rbxassetid://149679690",   Lf="rbxassetid://149679709",   Rt="rbxassetid://149679722",   Up="rbxassetid://149680199"},
}

local customSky = nil
local currentSky = "HD"

local function applySkybox(name)
    if customSky then customSky:Destroy() end
    local data = skyAssets[name]
    if not data then return end
    customSky = Instance.new("Sky")
    customSky.Name = "LithiumSky"
    customSky.SkyboxBk = data.Bk
    customSky.SkyboxDn = data.Dn
    customSky.SkyboxFt = data.Ft
    customSky.SkyboxLf = data.Lf
    customSky.SkyboxRt = data.Rt
    customSky.SkyboxUp = data.Up
    customSky.Parent = Lighting
end

local function restoreSky()
    if customSky then customSky:Destroy() customSky = nil end
    if defaultSky and defaultSkybox then
        defaultSky.SkyboxBk = defaultSkybox.Bk
        defaultSky.SkyboxDn = defaultSkybox.Dn
        defaultSky.SkyboxFt = defaultSkybox.Ft
        defaultSky.SkyboxLf = defaultSkybox.Lf
        defaultSky.SkyboxRt = defaultSkybox.Rt
        defaultSky.SkyboxUp = defaultSkybox.Up
        defaultSky.Parent = Lighting
    end
end

Group:AddToggle('CustomSkyboxEnabled', {
    Text = 'Custom Skybox',
    Default = false,
    Callback = function(v) if v then applySkybox(currentSky) else restoreSky() end end,
})
Group:AddDropdown('SkyboxSelected', {
    Values = {"Black Storm","HD","Snow","Blue Space","Realistic","Stormy","Pink","Sunset","Arctic","Space","Roblox Default","Red Night","Deep Space 1","Pink Skies","Purple Sunset","Blue Night","Blossom Daylight","Blue Nebula","Blue Planet","Deep Space 2","Summer","Galaxy","Stylized","Minecraft","Cloudy Rain","Black Cloudy Rain"},
    Default = "Snow",
    Multi = false,
    Text = 'Skybox',
    Callback = function(v)
        currentSky = v
        if _G.LITHIUM.Toggles.CustomSkyboxEnabled.Value then applySkybox(v) end
    end,
})

return World