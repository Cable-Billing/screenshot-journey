local panel = CreateFrame("Frame", "ScreenshotJourneyOptionsPanel", UIParent)
panel.name = "Screenshot Journey"

local scrollFrame = CreateFrame("ScrollFrame", "ScreenshotJourneyScrollFrame", panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 0, -8)
scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

local scrollStep = 25 -- pixels to scroll per step, reduce this to scroll less each time

scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local curr = self:GetVerticalScroll()
    local max = self:GetVerticalScrollRange()
    local newScroll = curr - delta * scrollStep
    if newScroll < 0 then newScroll = 0 end
    if newScroll > max then newScroll = max end
    self:SetVerticalScroll(newScroll)
end)

local content = CreateFrame("Frame", "ScreenshotJourneyScrollContent", scrollFrame)
content:SetSize(1, 1) -- will auto expand with contents
scrollFrame:SetScrollChild(content)

local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Screenshot Journey Settings v1.5")

-- Warning and information section at the top of the options
local lblWarning = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
lblWarning:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
lblWarning:SetText("Settings are saved on a per character basis")
lblWarning:SetTextColor(1, 0.3, 0.3)

local lblInfo1 = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
lblInfo1:SetPoint("TOPLEFT", lblWarning, "BOTTOMLEFT", 0, -6)
lblInfo1:SetText("Active issues can be viewed on the GitHub issues page")

local lblInfo2 = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
lblInfo2:SetPoint("TOPLEFT", lblInfo1, "BOTTOMLEFT", 0, -6)
lblInfo2:SetText("You can also report issues there")

local txtIssuesURL = CreateFrame("EditBox", "SJ_TXT_IssuesURL", content, "InputBoxTemplate")
txtIssuesURL:SetSize(350, 20)
txtIssuesURL:SetPoint("TOPLEFT", lblInfo2, "BOTTOMLEFT", 0, -4)
txtIssuesURL:SetAutoFocus(false)
txtIssuesURL:SetCursorPosition(0)
txtIssuesURL:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
txtIssuesURL:SetScript("OnMouseUp", function(self) self:HighlightText() end)
txtIssuesURL:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
txtIssuesURL:SetScript("OnShow", function(self) self:SetText("https://github.com/Cable-Billing/screenshot-journey/issues") end)

local function CreateCheckbox(name, label, tooltip, settingKey)
    local cb = CreateFrame("CheckButton", name, content, "InterfaceOptionsCheckButtonTemplate")
    _G[cb:GetName() .. "Text"]:SetText(label)

    cb:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(label)
        if tooltip then
            GameTooltip:AddLine(tooltip, 1, 1, 1, true)
        end
        GameTooltip:Show()
    end)

    cb:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    cb:SetScript("OnClick", function(self)
        local val = self:GetChecked() and true or false
        ScreenshotJourney_Config[settingKey] = val
    end)

    return cb
end

local cbLevelUp = CreateCheckbox("SJ_CB_LevelUp", "Level Up", "Take a screenshot you level up", "levelUp")
cbLevelUp:SetPoint("TOPLEFT", txtIssuesURL, "BOTTOMLEFT", 0, -12)

local cbDeath = CreateCheckbox("SJ_CB_Death", "Death", "Take a screenshot when you die", "death")
cbDeath:SetPoint("TOPLEFT", cbLevelUp, "BOTTOMLEFT", 0, -8)

local cbAchievementEarned = CreateCheckbox("SJ_CB_AchievementEarned", "Achievement Earned", "Take a screenshot when you earn an achievement", "achievementEarned")
cbAchievementEarned:SetPoint("TOPLEFT", cbDeath, "BOTTOMLEFT", 0, -8)

local cbFirstTimeLocation = CreateCheckbox("SJ_CB_FirstTimeLocation", "First Time Visiting a Location", "Take a screenshot the first time you enter a zone or sub-zone", "firstTimeVisitingLocation")
cbFirstTimeLocation:SetPoint("TOPLEFT", cbAchievementEarned, "BOTTOMLEFT", 0, -8)

local cbBossKill = CreateCheckbox("SJ_CB_BossKill", "Boss Kill", "Take a screenshot when you or your party kills an instance boss", "bossKill")
cbBossKill:SetPoint("TOPLEFT", cbFirstTimeLocation, "BOTTOMLEFT", 0, -8)

local cbLootRoll = CreateCheckbox("SJ_CB_LootRoll", "Loot Roll", "Take a screenshot when loot is to be rolled on", "lootRoll")
cbLootRoll:SetPoint("TOPLEFT", cbBossKill, "BOTTOMLEFT", 0, -8)

local cbLootRollGreen = CreateCheckbox("SJ_CB_LootGreen", "Green (Uncommon)", "Take a screenshot on green (uncommon) loot is rolled on", "lootRollGreen")
cbLootRollGreen:SetPoint("TOPLEFT", cbLootRoll, "BOTTOMLEFT", 20, -4)
_G[cbLootRollGreen:GetName() .. "Text"]:SetText(ITEM_QUALITY_COLORS[2].hex .. "Green (Uncommon)|r")

local cbLootRollBlue = CreateCheckbox("SJ_CB_LootBlue", "Blue (Rare)", "Take a screenshot on blue (rare) loot is rolled on", "lootRollBlue")
cbLootRollBlue:SetPoint("TOPLEFT", cbLootRollGreen, "BOTTOMLEFT", 0, -4)
_G[cbLootRollBlue:GetName() .. "Text"]:SetText(ITEM_QUALITY_COLORS[3].hex .. "Blue (Rare)|r")

local cbLootRollPurple = CreateCheckbox("SJ_CB_LootPurple", "Purple (Epic)", "Take a screenshot on purple (epic) loot is rolled on", "lootRollPurple")
cbLootRollPurple:SetPoint("TOPLEFT", cbLootRollBlue, "BOTTOMLEFT", 0, -4)
_G[cbLootRollPurple:GetName() .. "Text"]:SetText(ITEM_QUALITY_COLORS[4].hex .. "Purple (Epic)|r")

local cbLootRollOrange = CreateCheckbox("SJ_CB_LootOrange", "Orange (Legendary)", "Take a screenshot on orange (legendary) loot is rolled on", "lootRollOrange")
cbLootRollOrange:SetPoint("TOPLEFT", cbLootRollPurple, "BOTTOMLEFT", 0, -4)
_G[cbLootRollOrange:GetName() .. "Text"]:SetText(ITEM_QUALITY_COLORS[5].hex .. "Orange (Legendary)|r")

-- Overrides the created in CreateCheckbox, that it why it needs to set the value in the config as well
cbLootRoll:SetScript("OnClick", function(self)
    local val = self:GetChecked() and true or false
    ScreenshotJourney_Config.lootRoll = val
    if val then
        cbLootRollGreen:Enable()
        cbLootRollBlue:Enable()
        cbLootRollPurple:Enable()
        cbLootRollOrange:Enable()
    else
        cbLootRollGreen:Disable()
        cbLootRollBlue:Disable()
        cbLootRollPurple:Disable()
        cbLootRollOrange:Disable()
    end
end)

local cbLootReceived = CreateCheckbox("SJ_CB_LootReceived", "Loot Received", "Take a screenshot when you receive loot, or win it from a roll", "lootReceived")
cbLootReceived:SetPoint("LEFT", cbLootRoll, "RIGHT", 160, 0)

local cbLootReceivedGreen = CreateCheckbox("SJ_CB_LootReceivedGreen", "Green (Uncommon)", "Take a screenshot on green (uncommon) loot received, or won", "lootReceivedGreen")
cbLootReceivedGreen:SetPoint("TOPLEFT", cbLootReceived, "BOTTOMLEFT", 20, -4)
_G[cbLootReceivedGreen:GetName() .. "Text"]:SetText(ITEM_QUALITY_COLORS[2].hex .. "Green (Uncommon)|r")

local cbLootReceivedBlue = CreateCheckbox("SJ_CB_LootReceivedBlue", "Blue (Rare)", "Take a screenshot on blue (rare) loot received, or won", "lootReceivedBlue")
cbLootReceivedBlue:SetPoint("TOPLEFT", cbLootReceivedGreen, "BOTTOMLEFT", 0, -4)
_G[cbLootReceivedBlue:GetName() .. "Text"]:SetText(ITEM_QUALITY_COLORS[3].hex .. "Blue (Rare)|r")

local cbLootReceivedPurple = CreateCheckbox("SJ_CB_LootReceivedPurple", "Purple (Epic)", "Take a screenshot on purple (epic) loot received, or won", "lootReceivedPurple")
cbLootReceivedPurple:SetPoint("TOPLEFT", cbLootReceivedBlue, "BOTTOMLEFT", 0, -4)
_G[cbLootReceivedPurple:GetName() .. "Text"]:SetText(ITEM_QUALITY_COLORS[4].hex .. "Purple (Epic)|r")

local cbLootReceivedOrange = CreateCheckbox("SJ_CB_LootReceivedOrange", "Orange (Legendary)", "Take a screenshot on orange (legendary) loot received, or won", "lootReceivedOrange")
cbLootReceivedOrange:SetPoint("TOPLEFT", cbLootReceivedPurple, "BOTTOMLEFT", 0, -4)
_G[cbLootReceivedOrange:GetName() .. "Text"]:SetText(ITEM_QUALITY_COLORS[5].hex .. "Orange (Legendary)|r")

cbLootReceived:SetScript("OnClick", function(self)
    local val = self:GetChecked() and true or false
    ScreenshotJourney_Config.lootReceived = val
    if val then
        cbLootReceivedGreen:Enable()
        cbLootReceivedBlue:Enable()
        cbLootReceivedPurple:Enable()
        cbLootReceivedOrange:Enable()
    else
        cbLootReceivedGreen:Disable()
        cbLootReceivedBlue:Disable()
        cbLootReceivedPurple:Disable()
        cbLootReceivedOrange:Disable()
    end
end)

local cbPvPKill = CreateCheckbox("SJ_CB_PvPKill", "PvP Kill", "Take a screenshot when you or your party kills another player", "pvpKill")
cbPvPKill:SetPoint("TOPLEFT", cbLootRollOrange, "BOTTOMLEFT", -20, -8)

local cbDuelFinished = CreateCheckbox("SJ_CB_DuelFinished", "Duel Finished", "Take a screenshot at the end of a duel, both winning and losing", "duelFinished")
cbDuelFinished:SetPoint("TOPLEFT", cbPvPKill, "BOTTOMLEFT", 0, -8)

local cbBattlegroundArenaEnd = CreateCheckbox("SJ_CB_BattlegroundArenaEnd", "Battleground/Arena End", "Take a screenshot when a battleground or arena match ends and scoreboard appears", "battlegroundArenaEnd")
cbBattlegroundArenaEnd:SetPoint("TOPLEFT", cbDuelFinished, "BOTTOMLEFT", 0, -8)

local cbPeriodic = CreateCheckbox("SJ_CB_Periodic", "Periodic Screenshot", "Take a screenshot every set periodic interval", "periodic")
cbPeriodic:SetPoint("TOPLEFT", cbBattlegroundArenaEnd, "BOTTOMLEFT", 0, -8)

local txtInterval = CreateFrame("EditBox", "SJ_TXT_Interval", content, "InputBoxTemplate")
txtInterval:SetSize(60, 20)
txtInterval:SetPoint("LEFT", cbPeriodic, "RIGHT", 132, 0)
txtInterval:SetAutoFocus(false)
txtInterval:SetNumeric(true)

txtInterval:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Interval (seconds)", 1, 0.82, 0)
    GameTooltip:AddLine("The number of seconds between each periodic screenshot with a minimum of 300 seconds", 1, 1, 1, true)
    GameTooltip:AddLine("Press ENTER to save", 1, 0, 0, true)
    GameTooltip:Show()
end)

txtInterval:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

local lblInterval = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
lblInterval:SetPoint("LEFT", txtInterval, "RIGHT", 4, 0)
lblInterval:SetText("Interval (seconds)")

-- Overrides the created in CreateCheckbox, that it why it needs to set the value in the config as well
cbPeriodic:SetScript("OnClick", function(self)
    local val = self:GetChecked() and true or false
    ScreenshotJourney_Config.periodic = val
    if val then
        txtInterval:EnableMouse(true)
        txtInterval:SetTextColor(1, 1, 1)
    else
        txtInterval:EnableMouse(false)
        txtInterval:ClearFocus()
        txtInterval:SetTextColor(0.5, 0.5, 0.5)
    end
end)

txtInterval:SetScript("OnEnterPressed", function(self)
    local num = tonumber(self:GetText())
    if num and num >= 300 then
        ScreenshotJourney_Config.periodicInterval = num
    else
        self:SetText(tostring(ScreenshotJourney_Config.periodicInterval))
    end
    self:ClearFocus()
end)

txtInterval:SetScript("OnEscapePressed", function(self)
    self:SetText(tostring(ScreenshotJourney_Config.periodicInterval))
    self:ClearFocus()
end)

-- Can't set this in the panel.refresh, have to do it when the text box becomes visible
txtInterval:SetScript("OnShow", function(self)
    if not self:HasFocus() then
        self:SetText(tostring(ScreenshotJourney_Config.periodicInterval))
    end
end)

panel.refresh = function()
    cbLevelUp:SetChecked(ScreenshotJourney_Config.levelUp)
    cbDeath:SetChecked(ScreenshotJourney_Config.death)
    cbAchievementEarned:SetChecked(ScreenshotJourney_Config.achievementEarned)
    cbFirstTimeLocation:SetChecked(ScreenshotJourney_Config.firstTimeVisitingLocation)
    cbBossKill:SetChecked(ScreenshotJourney_Config.bossKill)
    cbLootRoll:SetChecked(ScreenshotJourney_Config.lootRoll)
    cbLootRollGreen:SetChecked(ScreenshotJourney_Config.lootRollGreen)
    cbLootRollBlue:SetChecked(ScreenshotJourney_Config.lootRollBlue)
    cbLootRollPurple:SetChecked(ScreenshotJourney_Config.lootRollPurple)
    cbLootRollOrange:SetChecked(ScreenshotJourney_Config.lootRollOrange)
    cbLootReceived:SetChecked(ScreenshotJourney_Config.lootReceived)
    cbLootReceivedGreen:SetChecked(ScreenshotJourney_Config.lootReceivedGreen)
    cbLootReceivedBlue:SetChecked(ScreenshotJourney_Config.lootReceivedBlue)
    cbLootReceivedPurple:SetChecked(ScreenshotJourney_Config.lootReceivedPurple)
    cbLootReceivedOrange:SetChecked(ScreenshotJourney_Config.lootReceivedOrange)
    cbPvPKill:SetChecked(ScreenshotJourney_Config.pvpKill)
    cbDuelFinished:SetChecked(ScreenshotJourney_Config.duelFinished)
    cbBattlegroundArenaEnd:SetChecked(ScreenshotJourney_Config.battlegroundArenaEnd)
    cbPeriodic:SetChecked(ScreenshotJourney_Config.periodic)

    if ScreenshotJourney_Config.lootRoll then
        cbLootRollGreen:Enable()
        cbLootRollBlue:Enable()
        cbLootRollPurple:Enable()
        cbLootRollOrange:Enable()
    else
        cbLootRollGreen:Disable()
        cbLootRollBlue:Disable()
        cbLootRollPurple:Disable()
        cbLootRollOrange:Disable()
    end

    if ScreenshotJourney_Config.lootReceived then
        cbLootReceivedGreen:Enable()
        cbLootReceivedBlue:Enable()
        cbLootReceivedPurple:Enable()
        cbLootReceivedOrange:Enable()
    else
        cbLootReceivedGreen:Disable()
        cbLootReceivedBlue:Disable()
        cbLootReceivedPurple:Disable()
        cbLootReceivedOrange:Disable()
    end

    if ScreenshotJourney_Config.periodic then
        txtInterval:EnableMouse(true)
        txtInterval:SetTextColor(1, 1, 1)
    else
        txtInterval:EnableMouse(false)
        txtInterval:ClearFocus()
        txtInterval:SetTextColor(0.5, 0.5, 0.5)
    end
end

InterfaceOptions_AddCategory(panel)
