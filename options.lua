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

local cbQuestComplete = CreateCheckbox("SJ_CB_QuestComplete", "Quest Complete", "Take screenshot when you complete a quest", "questComplete")
cbQuestComplete:SetPoint("TOPLEFT", cbDeath, "BOTTOMLEFT", 0, -8)

local cbBossKill = CreateCheckbox("SJ_CB_BossKill", "Boss Kill", "Take screenshot when you or your party kills an instance boss", "bossKill")
cbBossKill:SetPoint("TOPLEFT", cbQuestComplete, "BOTTOMLEFT", 0, -8)

local cbPvPKill = CreateCheckbox("SJ_CB_PvPKill", "PvP Kill", "Take screenshot when you or your party kills another player", "pvpKill")
cbPvPKill:SetPoint("TOPLEFT", cbBossKill, "BOTTOMLEFT", 0, -8)

local cbPeriodic = CreateCheckbox("SJ_CB_Periodic", "Timed Screenshot", "Take screenshot every set periodic interval", "periodic")
cbPeriodic:SetPoint("TOPLEFT", cbPvPKill, "BOTTOMLEFT", 0, -8)

local slider = CreateFrame("Slider", "SJ_TimerSlider", panel, "OptionsSliderTemplate")
slider:SetWidth(200)
slider:SetHeight(16)
slider:SetOrientation('HORIZONTAL')
slider:SetPoint("TOPLEFT", cbPeriodic, "BOTTOMLEFT", 0, -24)
slider:SetMinMaxValues(60, 1800) -- 1 min to 30 min
slider:SetValueStep(60)
_G[slider:GetName() .. 'Low']:SetText('1m')
_G[slider:GetName() .. 'High']:SetText('30m')
_G[slider:GetName() .. 'Text']:SetText("Timer Interval (seconds)")

slider:SetScript("OnValueChanged", function(self, value)
    ScreenshotJourney_Config.periodicInterval = value
end)

panel.refresh = function()
    cbLevelUp:SetChecked(ScreenshotJourney_Config.levelUp)
    cbDeath:SetChecked(ScreenshotJourney_Config.death)
    cbQuestComplete:SetChecked(ScreenshotJourney_Config.questComplete)
    cbBossKill:SetChecked(ScreenshotJourney_Config.bossKill)
    cbPvPKill:SetChecked(ScreenshotJourney_Config.pvpKill)
    cbPeriodic:SetChecked(ScreenshotJourney_Config.periodic)
    slider:SetValue(ScreenshotJourney_Config.periodicInterval)
end

InterfaceOptions_AddCategory(panel)
