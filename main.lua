ScreenshotJourney_Config = ScreenshotJourney_Config or {
    killBoss = true,
    questComplete = true,
    pvpKill = true,
    levelUp = true,
    periodic = true,
    periodicInterval = 300,
}

local f = CreateFrame("Frame")
local elapsedSinceLast = 0

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
    end
end)

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("QUEST_TURNED_IN")
f:RegisterEvent("BOSS_KILL")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

f:SetScript("OnUpdate", function(self, elapsed)
    if ScreenshotJourney_Config.enableTimer then
        elapsedSinceLast = elapsedSinceLast + elapsed
        if elapsedSinceLast >= ScreenshotJourney_Config.timerInterval then
            elapsedSinceLast = 0
            Screenshot()
        end
    end
end)
