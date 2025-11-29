local playerFrame = CreateFrame("Frame", "DotWatchPlayerFrame", UIParent, "BackdropTemplate")
playerFrame:SetSize(150, 40)
playerFrame:SetPoint("TOP", DotWatchFrame, "BOTTOM", 0, -10)
playerFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
playerFrame:Show()

local playerHealthBar = CreateFrame("StatusBar", nil, playerFrame)
playerHealthBar:SetSize(130, 12)
playerHealthBar:SetPoint("TOP", 0, -8)
playerHealthBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
playerHealthBar:GetStatusBarTexture():SetHorizTile(false)
playerHealthBar:SetStatusBarColor(0, 1, 0)

local playerManaBar = CreateFrame("StatusBar", nil, playerFrame)
playerManaBar:SetSize(130, 12)
playerManaBar:SetPoint("TOP", playerHealthBar, "BOTTOM", 0, -4)
playerManaBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
playerManaBar:GetStatusBarTexture():SetHorizTile(false)
playerManaBar:SetStatusBarColor(0, 0, 1)

local function UpdatePlayerStatus()
    local health = UnitHealth("player")
    local healthMax = UnitHealthMax("player")
    local mana = UnitPower("player")
    local manaMax = UnitPowerMax("player")

    playerHealthBar:SetMinMaxValues(0, healthMax)
    playerHealthBar:SetValue(health)

    playerManaBar:SetMinMaxValues(0, manaMax)
    playerManaBar:SetValue(mana)
end

local playerFrameUpdater = CreateFrame("Frame")
playerFrameUpdater:SetScript("OnUpdate", function(self, elapsed)
    UpdatePlayerStatus()
end)
