ScreenshotJourney_Config = ScreenshotJourney_Config or {
    levelUp = true,
    questComplete = true,
    bossKill = true,
    pvpKill = true,
    periodic = true,
    periodicInterval = 300,
}

local f = CreateFrame("Frame")
local elapsedSinceLast = 0
local delayQueue = {}

local function TakeScreenshotDelayed(delay)
    table.insert(delayQueue, delay)
end

f:SetScript("OnEvent", function(self, event, ...)
    local function queueScreenshot()
        TakeScreenshotDelayed(0.1)
    end

    if event == "PLAYER_LEVEL_UP" and ScreenshotJourney_Config.levelUp then
        queueScreenshot()
    elseif event == "QUEST_TURNED_IN" and ScreenshotJourney_Config.questComplete then
        queueScreenshot()
    elseif event == "BOSS_KILL" and ScreenshotJourney_Config.bossKill then
        queueScreenshot()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and ScreenshotJourney_Config.pvpKill then
        local _, subEvent, _, _, _, _, _, destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()
        if subEvent == "PARTY_KILL" and bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
            queueScreenshot()
        end
    end
end)

f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("QUEST_TURNED_IN")
f:RegisterEvent("BOSS_KILL")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

f:SetScript("OnUpdate", function(self, elapsed)
    -- Process periodic screenshots
    if ScreenshotJourney_Config.periodic then
        elapsedSinceLast = elapsedSinceLast + elapsed
        if elapsedSinceLast >= ScreenshotJourney_Config.periodicInterval then
            elapsedSinceLast = 0
            TakeScreenshotDelayed(0.1)
        end
    end

    -- Process delay queue
    for i = #delayQueue, 1, -1 do
        delayQueue[i] = delayQueue[i] - elapsed
        if delayQueue[i] <= 0 then
            Screenshot()
            table.remove(delayQueue, i)
        end
    end
end)
