local Hook = {}

local BLOCKED = {
    ["TeleportDetect"]  = true,
    ["CHECKER_1"]       = true,
    ["CHECKER"]         = true,
    ["GUI_CHECK"]       = true,
    ["OneMoreTime"]     = true,
    ["checkingSPEED"]   = true,
    ["BANREMOTE"]       = true,
    ["PERMAIDBAN"]      = true,
    ["KICKREMOTE"]      = true,
    ["BR_KICKPC"]       = true,
    ["BR_KICKMOBILE"]   = true,
}

function Hook.install()
    if not (getnamecallmethod and getrawmetatable and setreadonly and newcclosure) then
        warn("[Lithium] executor missing metatable primitives; hook not installed")
        return false
    end
    local ok, err = pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local old = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local remoteName = tostring(args[1])
            if BLOCKED[remoteName] then return end
            return old(self, ...)
        end)
    end)
    if not ok then
        warn("[Lithium] hook install failed: " .. tostring(err))
        return false
    end
    warn("[Lithium] remote blocklist active")
    return true
end

return Hook