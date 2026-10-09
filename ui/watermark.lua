local Stats = game:GetService("Stats")
local frameTimer, frameCounter = tick(), 0
local fps = 60
local startTime = tick()

local function executorName()
    if identifyexecutor then return identifyexecutor() end
    if syn then return "Synapse X" end
    return "Unknown"
end

RunService.RenderStepped:Connect(function()
    frameCounter += 1
    if tick() - frameTimer >= 1 then
        fps = frameCounter
        frameTimer = tick()
        frameCounter = 0
    end
    local ping = 0
    pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    local uptime = math.floor(tick() - startTime)
    local uptimeStr = string.format("%02d:%02d", math.floor(uptime/60), uptime%60)

    local parts = {"lithium"}
    if Config.Watermark.ShowExecutor then table.insert(parts, executorName()) end
    if Config.Watermark.ShowGameName then table.insert(parts, "Da Hood (" .. game.PlaceId .. ")") end
    if Config.Watermark.ShowUptime then table.insert(parts, "Uptime: " .. uptimeStr) end
    if Config.Watermark.ShowFPS then table.insert(parts, "FPS " .. math.floor(fps)) end
    if Config.Watermark.ShowPing then table.insert(parts, ping .. "ms") end

    Library:SetWatermark(table.concat(parts, " | "))
    Library:SetWatermarkVisibility(Config.Watermark.Enabled)
end)

local Group = Tabs.Settings:AddRightGroupbox('Watermark')
Group:AddToggle('WatermarkEnabled',      { Text = 'Enabled',            Default = true,  Callback = function(v) Config.Watermark.Enabled = v end })
Group:AddToggle('WatermarkShowFPS',      { Text = 'Show FPS',           Default = true,  Callback = function(v) Config.Watermark.ShowFPS = v end })
Group:AddToggle('WatermarkShowGameName', { Text = 'Show Game Name',     Default = false, Callback = function(v) Config.Watermark.ShowGameName = v end })
Group:AddToggle('WatermarkShowUptime',   { Text = 'Show Uptime',        Default = false, Callback = function(v) Config.Watermark.ShowUptime = v end })
Group:AddToggle('WatermarkShowExecutor', { Text = 'Show Executor',      Default = false, Callback = function(v) Config.Watermark.ShowExecutor = v end })
Group:AddToggle('WatermarkShowPing',     { Text = 'Show Ping',          Default = true,  Callback = function(v) Config.Watermark.ShowPing = v end })