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
    -- Add a new delay timer to the queue
    table.insert(delayQueue, delay)
end

local function QueueScreenshot()
    TakeScreenshotDelayed(0.1)
end

f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LEVEL_UP" and ScreenshotJourney_Config.levelUp then
        QueueScreenshot()
    elseif event == "QUEST_TURNED_IN" and ScreenshotJourney_Config.questComplete then
        QueueScreenshot()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

        if subEvent == "PARTY_KILL" and destGUID then
            -- print("timestamp " .. tostring(timestamp))
            -- print("subEvent " .. tostring(subEvent))
            -- print("hideCaster " .. tostring(hideCaster))
            -- print("sourceGUID " .. tostring(sourceGUID))
            -- print("sourceName " .. tostring(sourceName))
            -- print("sourceFlags " .. tostring(sourceFlags))
            -- print("sourceRaidFlags " .. tostring(sourceRaidFlags))
            -- print("destGUID " .. tostring(destGUID))
            -- print("destName " .. tostring(destName))
            -- print("destFlags " .. tostring(destFlags))
            -- print("destRaidFlags " .. tostring(destRaidFlags))
            if bit.band(destGUID, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 and ScreenshotJourney_Config.pvpKill then
                QueueScreenshot()
            elseif bit.band(destGUID, COMBATLOG_OBJECT_TYPE_NPC) > 0 and ScreenshotJourney_Config.bossKill then
                -- print("killed npc")
                -- QueueScreenshot()
            end
        end
    end
end)

f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("QUEST_TURNED_IN")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

f:SetScript("OnUpdate", function(self, elapsed)
    -- Periodic screenshot timer
    if ScreenshotJourney_Config.periodic then
        elapsedSinceLast = elapsedSinceLast + elapsed
        if elapsedSinceLast >= ScreenshotJourney_Config.periodicInterval then
            elapsedSinceLast = 0
            TakeScreenshotDelayed(0.1)
        end
    end

    -- Process delayed screenshots
    for i = #delayQueue, 1, -1 do
        delayQueue[i] = delayQueue[i] - elapsed
        if delayQueue[i] <= 0 then
            Screenshot()
            table.remove(delayQueue, i)
        end
    end
end)
