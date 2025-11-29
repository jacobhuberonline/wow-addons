local function DrawPlayerBox()

    local ICON_SIZE = 40
    local frame = CreateFrame("Frame", "DotWatchPlayerFrame", UIParent, "BackdropTemplate")
    frame.iconSize = ICON_SIZE
    frame:SetSize(ICON_SIZE, ICON_SIZE)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 4,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.85)
    frame:SetBackdropBorderColor(0.3, 0.7, 1.0, 0.9)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 70) -- slightly higher position

    frame.healthBar = CreateFrame("StatusBar", nil, frame)
    frame.healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    frame.healthBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    frame.healthBar:SetHeight(frame.iconSize / 5)
    frame.healthBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    frame.healthBar:SetStatusBarColor(0.6, 1.0, 0.6)

    frame.healthText = frame.healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.healthText:SetPoint("CENTER", frame.healthBar, "CENTER", 0, 0)
    frame.healthText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    frame.healthText:SetJustifyH("CENTER")
    frame.healthText:SetJustifyV("MIDDLE")
    frame.healthText:SetText("")

    frame.powerBar = CreateFrame("StatusBar", nil, frame)
    frame.powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, -2)
    frame.powerBar:SetPoint("TOPRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, -2)
    frame.powerBar:SetHeight(frame.iconSize / 5)
    frame.powerBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")

    frame.shardText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.shardText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
    frame.shardText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
    frame.shardText:SetJustifyH("LEFT")
    frame.shardText:SetText("0")

    frame.buffText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.buffText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
    frame.buffText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
    frame.buffText:SetJustifyH("RIGHT")
    frame.buffText:SetText("")
    frame.buffText:SetTextColor(1, 0, 0, 1)

    frame:SetScript("OnUpdate", function()
        local health = UnitHealth("player")
        local healthMax = UnitHealthMax("player")
        frame.healthBar:SetMinMaxValues(0, healthMax)
        frame.healthBar:SetValue(health)
        frame.healthText:SetText(string.format("%d", health))

        local power = UnitPower("player")
        local powerMax = UnitPowerMax("player")
        local _, powerTypeToken = UnitPowerType("player")
        local color = PowerColors and PowerColors[powerTypeToken] or { r = 0.2, g = 0.4, b = 1 }
        frame.powerBar:SetMinMaxValues(0, powerMax)
        frame.powerBar:SetValue(power)
        frame.powerBar:SetStatusBarColor(color.r, color.g, color.b)

        local shardCount = 0
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemId = C_Container.GetContainerItemID(bag, slot)
                if itemId == 6265 then -- Soul Shard item ID
                    shardCount = shardCount + 1
                end
            end
        end
        frame.shardText:SetText("" .. shardCount)

        local hasDemonArmor = AuraUtil.FindAuraByName("Demon Armor", "player", "HELPFUL")
        if not hasDemonArmor then
            frame.buffText:SetText("DA")
            frame.buffText:SetTextColor(1, 0, 0, 1) -- Red
        else
            frame.buffText:SetText("")
        end
    end)
end

DrawPlayerBox()