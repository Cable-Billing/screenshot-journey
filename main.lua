-- ScreenshotJourney: main.lua
-- Default configuration
ScreenshotJourney_Config = ScreenshotJourney_Config or {
    killBoss = true,
    questComplete = true,
    pvpKill = true,
    levelUp = true,
    periodic = true,
    periodicInterval = 300, -- 5 minutes in seconds
}

local f = CreateFrame("Frame")
local periodicTimer = 0

-- Helper to take screenshot
local function TakeScreenshot()
    Screenshot()
end

-- Check if a unit is a boss
local function IsBoss(unitGUID)
    -- In 3.3.5a, boss units in instances often have "Creature" type with level -1 (??)
    if UnitExists(unitGUID) then
        local level = UnitLevel(unitGUID)
        return (level == -1)
    end
    return false
end

-- Event handler
f:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, hideCaster,
              sourceGUID, sourceName, sourceFlags,
              destGUID, destName, destFlags = ...

        -- Boss kill detection
        if ScreenshotJourney_Config.killBoss and subevent == "UNIT_DIED" then
            -- We can't directly check by GUID in 3.3.5a without a table of bosses,
            -- so we look for "??" units in instance combat or known boss names.
            -- For now, very basic check:
            if bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 and
               bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_NPC) > 0 then
                TakeScreenshot()
            end
        end

        -- PvP kill detection
        if ScreenshotJourney_Config.pvpKill and subevent == "PARTY_KILL" then
            if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
                TakeScreenshot()
            end
        end

    elseif event == "PLAYER_LEVEL_UP" then
        if ScreenshotJourney_Config.levelUp then
            TakeScreenshot()
        end

    elseif event == "QUEST_TURNED_IN" then
        if ScreenshotJourney_Config.questComplete then
            TakeScreenshot()
        end
    end
end)

-- Periodic screenshot logic
f:SetScript("OnUpdate", function(self, elapsed)
    if ScreenshotJourney_Config.periodic then
        periodicTimer = periodicTimer + elapsed
        if periodicTimer >= ScreenshotJourney_Config.periodicInterval then
            periodicTimer = 0
            TakeScreenshot()
        end
    end
end)

-- Register events
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("QUEST_TURNED_IN")
