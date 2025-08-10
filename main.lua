local f = CreateFrame("Frame")

-- Default config
local defaults = {
    enableLevelUp = true,
    enableQuest = true,
    enableBoss = true,
    enablePvP = true,
    enableTimer = true,
    timerInterval = 300, -- seconds
}

-- Init config
local function InitConfig()
    if not ScreenshotJourney_Config then
        ScreenshotJourney_Config = {}
    end
    for k, v in pairs(defaults) do
        if ScreenshotJourney_Config[k] == nil then
            ScreenshotJourney_Config[k] = v
        end
    end
end

-- Timer tracking
local elapsedSinceLast = 0

-- Event handler
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LEVEL_UP" and ScreenshotJourney_Config.enableLevelUp then
        Screenshot()
    elseif event == "QUEST_TURNED_IN" and ScreenshotJourney_Config.enableQuest then
        Screenshot()
    elseif event == "BOSS_KILL" and ScreenshotJourney_Config.enableBoss then
        Screenshot()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and ScreenshotJourney_Config.enablePvP then
        local _, subEvent, _, _, _, _, _, destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()
        if subEvent == "PARTY_KILL" and bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
            Screenshot()
        end
    elseif event == "PLAYER_LOGIN" then
        InitConfig()
    end
end)

-- Register events
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("QUEST_TURNED_IN")
f:RegisterEvent("BOSS_KILL")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- OnUpdate for periodic screenshots
f:SetScript("OnUpdate", function(self, elapsed)
    if ScreenshotJourney_Config.enableTimer then
        elapsedSinceLast = elapsedSinceLast + elapsed
        if elapsedSinceLast >= ScreenshotJourney_Config.timerInterval then
            elapsedSinceLast = 0
            Screenshot()
        end
    end
end)
