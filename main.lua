ScreenshotJourney_Config = ScreenshotJourney_Config or {
    levelUp = true,
    death = true,
    achievementEarned = true,
    questComplete = false,
    bossKill = true,
    lootRoll = true,
    lootRollGreen = false,
    lootRollBlue = true,
    lootRollPurple = true,
    lootRollOrange = true,
    pvpKill = true,
    periodic = false,
    periodicInterval = 1800,
}

-- TODO
-- When you recive loot from a roll
-- When a battleground ends
-- When an arena match ends

local f = CreateFrame("Frame")
local elapsedSinceLast = 0
local delayQueue = {}

local function TakeScreenshotDelayed(delay)
    -- Add a new delay timer to the queue
    table.insert(delayQueue, delay)
end

f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LEVEL_UP" and ScreenshotJourney_Config.levelUp then
        TakeScreenshotDelayed(0.1)
    elseif event == "PLAYER_DEAD" and ScreenshotJourney_Config.death then
        TakeScreenshotDelayed(0.1)
    elseif event == "ACHIEVEMENT_EARNED" and ScreenshotJourney_Config.achievementEarned then
        TakeScreenshotDelayed(1.0) -- Delay so achievement is clearly visible
    elseif event == "QUEST_TURNED_IN" and ScreenshotJourney_Config.questComplete then
        TakeScreenshotDelayed(0.1)
    elseif event == "START_LOOT_ROLL" and ScreenshotJourney_Config.lootRoll then
        local lootSlot = ...
        local texture, itemName, itemCount, quality = GetLootRollItemInfo(lootSlot)

        local shouldTake = false
        if quality == 2 and ScreenshotJourney_Config.lootRollGreen then
            shouldTake = true
        elseif quality == 3 and ScreenshotJourney_Config.lootRollBlue then
            shouldTake = true
        elseif quality == 4 and ScreenshotJourney_Config.lootRollPurple then
            shouldTake = true
        elseif quality == 5 and ScreenshotJourney_Config.lootRollOrange then
            shouldTake = true
        end

        if shouldTake then
            TakeScreenshotDelayed(0.1)
        end
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
                TakeScreenshotDelayed(0.1)
            elseif bit.band(destGUID, COMBATLOG_OBJECT_TYPE_NPC) > 0 and ScreenshotJourney_Config.bossKill then
                -- print("killed npc")
                -- TakeScreenshotDelayed(0.1)
            end
        end
    end
end)

f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("PLAYER_DEAD")
f:RegisterEvent("ACHIEVEMENT_EARNED")
f:RegisterEvent("QUEST_TURNED_IN")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("START_LOOT_ROLL")

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
