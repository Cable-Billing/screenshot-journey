local panel = CreateFrame("Frame", "ScreenshotJourneyOptionsPanel", UIParent)
panel.name = "Screenshot Journey"

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Screenshot Journey Settings")

local function CreateCheckbox(name, label, tooltip, settingKey)
    local cb = CreateFrame("CheckButton", name, panel, "InterfaceOptionsCheckButtonTemplate")
    _G[cb:GetName() .. "Text"]:SetText(label) -- Wrath-style label

    cb.tooltipText = label
    cb.tooltipRequirement = tooltip

    cb:SetScript("OnClick", function(self)
        ScreenshotJourney_Config[settingKey] = self:GetChecked()
    end)

    return cb
end

local cbLevelUp = CreateCheckbox("SJ_CB_LevelUp", "Level Up", "Take screenshot you level up", "levelUp")
cbLevelUp:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)

local cbDeath = CreateCheckbox("SJ_CB_Death", "Death", "Take screenshot when you die", "death")
cbDeath:SetPoint("TOPLEFT", cbLevelUp, "BOTTOMLEFT", 0, -8)

local cbAchievementEarned = CreateCheckbox("SJ_CB_AchievementEarned", "Achievement Earned", "Take screenshot when you earn an achievement", "achievementEarned")
cbAchievementEarned:SetPoint("TOPLEFT", cbDeath, "BOTTOMLEFT", 0, -8)

local cbQuestComplete = CreateCheckbox("SJ_CB_QuestComplete", "Quest Complete", "Take screenshot when you complete a quest", "questComplete")
cbQuestComplete:SetPoint("TOPLEFT", cbAchievementEarned, "BOTTOMLEFT", 0, -8)

local cbBossKill = CreateCheckbox("SJ_CB_BossKill", "Boss Kill", "Take screenshot when you or your party kills an instance boss", "bossKill")
cbBossKill:SetPoint("TOPLEFT", cbQuestComplete, "BOTTOMLEFT", 0, -8)

local cbLootRoll = CreateCheckbox("SJ_CB_LootRoll", "Loot Roll", "Take screenshot when loot is to be rolled on", "lootRoll")
cbLootRoll:SetPoint("TOPLEFT", cbBossKill, "BOTTOMLEFT", 0, -8)

local cbLootGreen = CreateCheckbox("SJ_CB_LootGreen", "Green (Uncommon)", "Take screenshot on green (uncommon) loot rolls", "lootRollGreen")
cbLootGreen:SetPoint("TOPLEFT", cbLootRoll, "BOTTOMLEFT", 20, -4)
_G[cbLootGreen:GetName() .. "Text"]:SetText(ITEM_QUALITY_COLORS[2].hex .. "Green (Uncommon)|r")

local cbLootBlue = CreateCheckbox("SJ_CB_LootBlue", "Blue (Rare)", "Take screenshot on blue (rare) loot rolls", "lootRollBlue")
cbLootBlue:SetPoint("TOPLEFT", cbLootGreen, "BOTTOMLEFT", 0, -4)
_G[cbLootBlue:GetName() .. "Text"]:SetText(ITEM_QUALITY_COLORS[3].hex .. "Blue (Rare)|r")

local cbLootPurple = CreateCheckbox("SJ_CB_LootPurple", "Purple (Epic)", "Take screenshot on purple (epic) loot rolls", "lootRollPurple")
cbLootPurple:SetPoint("TOPLEFT", cbLootBlue, "BOTTOMLEFT", 0, -4)
_G[cbLootPurple:GetName() .. "Text"]:SetText(ITEM_QUALITY_COLORS[4].hex .. "Purple (Epic)|r")

local cbLootOrange = CreateCheckbox("SJ_CB_LootOrange", "Orange (Legendary)", "Take screenshot on orange (legendary) loot rolls", "lootRollOrange")
cbLootOrange:SetPoint("TOPLEFT", cbLootPurple, "BOTTOMLEFT", 0, -4)
_G[cbLootOrange:GetName() .. "Text"]:SetText(ITEM_QUALITY_COLORS[5].hex .. "Orange (Legendary)|r")

-- Overrides the created in CreateCheckbox, that it why it needs to set the value in the config as well
cbLootRoll:SetScript("OnClick", function(self)
    ScreenshotJourney_Config.lootRoll = self:GetChecked()
    if self:GetChecked() then
        cbLootGreen:Enable()
        cbLootBlue:Enable()
        cbLootPurple:Enable()
        cbLootOrange:Enable()
    else
        cbLootGreen:Disable()
        cbLootBlue:Disable()
        cbLootPurple:Disable()
        cbLootOrange:Disable()
    end
end)

local cbPvPKill = CreateCheckbox("SJ_CB_PvPKill", "PvP Kill", "Take screenshot when you or your party kills another player", "pvpKill")
cbPvPKill:SetPoint("TOPLEFT", cbLootOrange, "BOTTOMLEFT", -20, -8)

local cbPeriodic = CreateCheckbox("SJ_CB_Periodic", "Timed Screenshot", "Take screenshot every set periodic interval", "periodic")
cbPeriodic:SetPoint("TOPLEFT", cbPvPKill, "BOTTOMLEFT", 0, -8)

local lblInterval = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
lblInterval:SetPoint("LEFT", cbPeriodic, "RIGHT", 116, 0)
lblInterval:SetText("Interval (seconds)")

local txtInterval = CreateFrame("EditBox", "SJ_TXT_Interval", panel, "InputBoxTemplate")
txtInterval:SetSize(60, 20)
txtInterval:SetPoint("LEFT", lblInterval, "RIGHT", 8, 0)
txtInterval:SetAutoFocus(false)

txtInterval:SetScript("OnEnterPressed", function(self)
    local text = self:GetText()
    local num = tonumber(text)
    if num and num >= 1 then
        ScreenshotJourney_Config.periodicInterval = num
    else
        -- revert if invalid
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
    cbQuestComplete:SetChecked(ScreenshotJourney_Config.questComplete)
    cbBossKill:SetChecked(ScreenshotJourney_Config.bossKill)
    cbLootRoll:SetChecked(ScreenshotJourney_Config.lootRoll)
    cbLootGreen:SetChecked(ScreenshotJourney_Config.lootRollGreen)
    cbLootBlue:SetChecked(ScreenshotJourney_Config.lootRollBlue)
    cbLootPurple:SetChecked(ScreenshotJourney_Config.lootRollPurple)
    cbLootOrange:SetChecked(ScreenshotJourney_Config.lootRollOrange)
    cbPvPKill:SetChecked(ScreenshotJourney_Config.pvpKill)
    cbPeriodic:SetChecked(ScreenshotJourney_Config.periodic)

    if ScreenshotJourney_Config.lootRoll then
        cbLootGreen:Enable()
        cbLootBlue:Enable()
        cbLootPurple:Enable()
        cbLootOrange:Enable()
    else
        cbLootGreen:Disable()
        cbLootBlue:Disable()
        cbLootPurple:Disable()
        cbLootOrange:Disable()
    end
end

InterfaceOptions_AddCategory(panel)
