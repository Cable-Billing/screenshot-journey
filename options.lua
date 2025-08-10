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


local cbLevelUp = CreateCheckbox("SJ_CB_LevelUp", "Level Up", "Take screenshot when leveling up", "levelUp")
cbLevelUp:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)

local cbQuest = CreateCheckbox("SJ_CB_Quest", "Quest Complete", "Take screenshot when completing a quest", "questComplete")
cbQuest:SetPoint("TOPLEFT", cbLevelUp, "BOTTOMLEFT", 0, -8)

local cbBoss = CreateCheckbox("SJ_CB_Boss", "Boss Kill", "Take screenshot when killing an instance boss", "bossKill")
cbBoss:SetPoint("TOPLEFT", cbQuest, "BOTTOMLEFT", 0, -8)

local cbPvP = CreateCheckbox("SJ_CB_PvP", "PvP Kill", "Take screenshot when killing another player", "pvpKill")
cbPvP:SetPoint("TOPLEFT", cbBoss, "BOTTOMLEFT", 0, -8)

local cbTimer = CreateCheckbox("SJ_CB_Timer", "Timed Screenshot", "Take screenshot every set periodic interval", "periodic")
cbTimer:SetPoint("TOPLEFT", cbPvP, "BOTTOMLEFT", 0, -8)

local slider = CreateFrame("Slider", "SJ_TimerSlider", panel, "OptionsSliderTemplate")
slider:SetWidth(200)
slider:SetHeight(16)
slider:SetOrientation('HORIZONTAL')
slider:SetPoint("TOPLEFT", cbTimer, "BOTTOMLEFT", 0, -24)
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
    cbQuest:SetChecked(ScreenshotJourney_Config.questComplete)
    cbBoss:SetChecked(ScreenshotJourney_Config.bossKill)
    cbPvP:SetChecked(ScreenshotJourney_Config.pvpKill)
    cbTimer:SetChecked(ScreenshotJourney_Config.periodic)
    slider:SetValue(ScreenshotJourney_Config.periodicInterval)
end

InterfaceOptions_AddCategory(panel)
