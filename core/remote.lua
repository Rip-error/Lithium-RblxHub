local Remote = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

Remote.DaHoodPlaceId = 2788229376
Remote.IsDaHood = (game.PlaceId == Remote.DaHoodPlaceId)
Remote.Arg = "UpdateMousePos"

function Remote.getMain()
    for _, name in ipairs({"MainEvent", "MAINEVENT", "Remote", "Bullets"}) do
        local r = ReplicatedStorage:FindFirstChild(name)
        if r then return r end
    end
    local mr = ReplicatedStorage:FindFirstChild("MainRemotes")
    if mr and mr:FindFirstChild("MainRemoteEvent") then
        return mr.MainRemoteEvent
    end
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if packages then
        local knit = packages:FindFirstChild("Knit")
        if knit and knit:FindFirstChild("Services") then
            local toolService = knit.Services:FindFirstChild("ToolService")
            if toolService and toolService:FindFirstChild("RE") then
                local re = toolService.RE
                if re:FindFirstChild("UpdateAim") then return re.UpdateAim end
            end
        end
    end
    return nil
end

Remote.MainEvent = Remote.getMain()

return Remote