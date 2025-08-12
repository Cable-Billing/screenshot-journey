ScreenshotJourney_Config = ScreenshotJourney_Config or {}
ScreenshotJourney_VisitedLocations = ScreenshotJourney_VisitedLocations or {}

local DEFAULTS = {
    levelUp = true,
    death = true,
    achievementEarned = true,
    firstTimeVisitingLocation = true,
    bossKill = true,
    lootRoll = true,
    lootRollGreen = false,
    lootRollBlue = true,
    lootRollPurple = true,
    lootRollOrange = true,
    lootReceived = true,
    lootReceivedGreen = false,
    lootReceivedBlue = true,
    lootReceivedPurple = true,
    lootReceivedOrange = true,
    pvpKill = true,
    duelFinished = true,
    battlegroundArenaEnd = true,
    periodic = false,
    periodicInterval = 1800,
}

local function ApplyDefaults()
    for key, value in pairs(DEFAULTS) do
        if ScreenshotJourney_Config[key] == nil then
            ScreenshotJourney_Config[key] = value
        end
    end
end

local f = CreateFrame("Frame")
local elapsedSinceLast = 0
local delayQueue = {}

local function TakeScreenshotDelayed(delay)
    if #delayQueue > 0 then
        delayQueue[1] = delay
    else
        table.insert(delayQueue, delay)
    end
end

local function RegisterGameplayEvents()
    f:RegisterEvent("PLAYER_LEVEL_UP")
    f:RegisterEvent("PLAYER_DEAD")
    f:RegisterEvent("ACHIEVEMENT_EARNED")
    f:RegisterEvent("ZONE_CHANGED")
    f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    f:RegisterEvent("ZONE_CHANGED_INDOORS")
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    f:RegisterEvent("START_LOOT_ROLL")
    f:RegisterEvent("CHAT_MSG_LOOT")
    f:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
    f:RegisterEvent("DUEL_FINISHED")
end

f:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "screenshot-journey" then
            ApplyDefaults()
            RegisterGameplayEvents()
            self:UnregisterEvent("ADDON_LOADED")
            return
        end
    end

    if event == "PLAYER_LEVEL_UP" and ScreenshotJourney_Config.levelUp then
        TakeScreenshotDelayed(0.3)
    elseif event == "PLAYER_DEAD" and ScreenshotJourney_Config.death then
        TakeScreenshotDelayed(0.1)
    elseif event == "ACHIEVEMENT_EARNED" and ScreenshotJourney_Config.achievementEarned then
        TakeScreenshotDelayed(1.0) -- Delay so achievement is clearly visible
    elseif (event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED_INDOORS") and ScreenshotJourney_Config.firstTimeVisitingLocation then
        ScreenshotJourney_VisitedLocations = ScreenshotJourney_VisitedLocations or {}

        local zoneName = GetRealZoneText() or GetZoneText() or "Unknown Zone"
        local subZoneName = GetSubZoneText()
        local locationKey

        if subZoneName and subZoneName ~= "" and subZoneName ~= zoneName then
            locationKey = zoneName .. " - " .. subZoneName
        else
            locationKey = zoneName
        end

        if not ScreenshotJourney_VisitedLocations[locationKey] then
            ScreenshotJourney_VisitedLocations[locationKey] = true
            TakeScreenshotDelayed(1.1)
        end
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
    elseif event == "CHAT_MSG_LOOT" and ScreenshotJourney_Config.lootReceived then
        local msg = ...
        if msg:find("You receive loot") or msg:find("You won") then
            local itemLink = msg:match("(|c%x+|Hitem:.-|h%[.-%]|h|r)")
            if itemLink then
                local _, _, quality = GetItemInfo(itemLink)

                local shouldTake = false
                if quality == 2 and ScreenshotJourney_Config.lootReceivedGreen then
                    shouldTake = true
                elseif quality == 3 and ScreenshotJourney_Config.lootReceivedBlue then
                    shouldTake = true
                elseif quality == 4 and ScreenshotJourney_Config.lootReceivedPurple then
                    shouldTake = true
                elseif quality == 5 and ScreenshotJourney_Config.lootReceivedOrange then
                    shouldTake = true
                end

                if shouldTake then
                    TakeScreenshotDelayed(0.1)
                end
            end
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
    elseif event == "DUEL_FINISHED" and ScreenshotJourney_Config.duelFinished then
        TakeScreenshotDelayed(0.1)
    elseif event == "UPDATE_BATTLEFIELD_SCORE" and ScreenshotJourney_Config.battlegroundArenaEnd then
        local inInstance, instanceType = IsInInstance()

        if (instanceType == "pvp" or instanceType == "arena") then
            TakeScreenshotDelayed(0.5)
        end
    end
end)

f:RegisterEvent("ADDON_LOADED")

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
