local f = CreateFrame("Frame")

local defaults = {
    enableLevelUp = true,
    enableQuest = true,
    enableBoss = true,
    enablePvP = true,
    enableTimer = true,
    timerInterval = 300,
}

local function InitConfig()
    if not AutoScreenshot_Config then
        AutoScreenshot_Config = {}
    end
    for k, v in pairs(defaults) do
        if AutoScreenshot_Config[k] == nil then
            AutoScreenshot_Config[k] = v
        end
    end
end

local elapsedSinceLast = 0

f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LEVEL_UP" and AutoScreenshot_Config.enableLevelUp then
        Screenshot()
    elseif event == "QUEST_TURNED_IN" and AutoScreenshot_Config.enableQuest then
        Screenshot()
    elseif event == "BOSS_KILL" and AutoScreenshot_Config.enableBoss then
        Screenshot()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and AutoScreenshot_Config.enablePvP then
        local _, subEvent, _, _, _, _, _, destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()
        if subEvent == "PARTY_KILL" and bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
            Screenshot()
        end
    elseif event == "PLAYER_LOGIN" then
        InitConfig()
    end
end)

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("QUEST_TURNED_IN")
f:RegisterEvent("BOSS_KILL")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

f:SetScript("OnUpdate", function(self, elapsed)
    if AutoScreenshot_Config.enableTimer then
        elapsedSinceLast = elapsedSinceLast + elapsed
        if elapsedSinceLast >= AutoScreenshot_Config.timerInterval then
            elapsedSinceLast = 0
            Screenshot()
        end
    end
end)

SLASH_AUTOSCREENSHOT1 = "/as"
SlashCmdList["AUTOSCREENSHOT"] = function(msg)
    local cmd, arg = msg:match("^(%S+)%s*(%S*)$")
    if not cmd or cmd == "" then
        print("AutoScreenshot commands:")
        print("/as levelup on|off")
        print("/as quest on|off")
        print("/as boss on|off")
        print("/as pvp on|off")
        print("/as timer on|off")
        return
    end

    cmd = cmd:lower()
    arg = arg:lower()

    local keyMap = {
        levelup = "enableLevelUp",
        quest = "enableQuest",
        boss = "enableBoss",
        pvp = "enablePvP",
        timer = "enableTimer",
    }

    if keyMap[cmd] then
        AutoScreenshot_Config[keyMap[cmd]] = (arg == "on")
        print(cmd .. " screenshots " .. (AutoScreenshot_Config[keyMap[cmd]] and "enabled" or "disabled"))
    else
        print("Unknown command.")
    end
end
