local addonName = ...
local f = CreateFrame("Frame")
local lastTick = GetTime()
local tickInterval = 2
local comboCount = 0 
local lastComboTickTime = 0

local lastPassiveSync = 0        
local PASSIVE_COOLDOWN = 6       

local sampleWindow = {}          
local SAMPLE_SIZE  = 8           
local MAX_SAMPLE_GAIN = 500      
local prevTickTime = nil          

local lastLabelText = ""
local lastBarColor = ""

-- Forever uses the modern aura API and can return restricted values.
local function IsReadable(value)
    return not issecretvalue or not issecretvalue(value)
end

local function ReadMana()
    -- Do not query restricted combat power or carry combat samples into a drink.
    if InCombatLockdown() or UnitAffectingCombat("player") or UnitIsDeadOrGhost("player") then
        return nil
    end
    local mana = UnitPower("player", 0)
    local maximum = UnitPowerMax("player", 0)
    if not IsReadable(mana) or not IsReadable(maximum) then return nil end
    if type(mana) ~= "number" or type(maximum) ~= "number" or maximum <= 0 then return nil end
    return mana, maximum
end

local function IsDrinking()
    if InCombatLockdown() or UnitAffectingCombat("player") then return false end
    for i = 1, 40 do
        local name
        if C_UnitAuras and C_UnitAuras.GetBuffDataByIndex then
            local ok, aura = pcall(C_UnitAuras.GetBuffDataByIndex, "player", i)
            if not ok or not IsReadable(aura) then return false end
            if not aura then break end
            if issecrettable and issecrettable(aura) then return false end
            name = aura.name
        elseif UnitBuff then
            name = UnitBuff("player", i)
        else
            return false
        end
        if IsReadable(name) and type(name) == "string" and name:lower():find("drink", 1, true) then
            return true
        end
    end
    return false
end

DWT_Settings = DWT_Settings or {}

-- user option: show the bar even when mana is full
if DWT_Settings.showAtFullMana == nil then
    DWT_Settings.showAtFullMana = false   -- default: hide at 100 % mana
end
if DWT_Settings.height == nil then
    DWT_Settings.height = 12        -- default height
end

local tickBar = CreateFrame("StatusBar", "DrinkWalkTimer_Bar", UIParent, "BackdropTemplate")
tickBar:SetSize(DWT_Settings.width or 200, DWT_Settings.height or 12)
tickBar:SetMinMaxValues(0, tickInterval)
tickBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
tickBar:SetStatusBarColor(0.6, 0.8, 1.0) 
tickBar:SetMovable(true)
if tickBar.SetResizable then
    tickBar:SetResizable(true)
    if tickBar.SetMinResize then
        tickBar:SetMinResize(100, 8)      -- only a minimum; no maximum
    elseif tickBar.SetResizeBounds then
        tickBar:SetResizeBounds(100, 8)
    end
end
tickBar:EnableMouse(true)
tickBar:RegisterForDrag("LeftButton")
tickBar:SetScript("OnDragStart", tickBar.StartMoving)
tickBar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, xOfs, yOfs = self:GetPoint()
    DWT_Settings.pos = {point, xOfs, yOfs}
end)    

local bg = tickBar:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(true)
bg:SetColorTexture(0.85, 0.85, 0.85, 0.5)

local label = tickBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
label:SetPoint("CENTER")
label:SetText("2.00")

local comboLabel = tickBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")  
comboLabel:SetPoint("BOTTOM", tickBar, "TOP", 0, 4)
comboLabel:SetText("") 

tickBar:SetValue(0)

local marker = tickBar:CreateTexture(nil, "OVERLAY")
marker:SetColorTexture(1.0, 0.8, 0.4, 0.8)  
marker:SetWidth(2)
marker:SetHeight(tickBar:GetHeight())
marker:SetPoint("LEFT", tickBar, "LEFT", 150, 0)  

tickBar:HookScript("OnSizeChanged", function(self, width, height)
    -- Enforce minimums live while dragging
    if width < 100 then
        width = 100
        self:SetWidth(100)
    end
    local h = height or self:GetHeight()
    if h < 8 then
        h = 8
        self:SetHeight(8)
    end

    -- Re‑position / resize marker
    marker:ClearAllPoints()
    marker:SetHeight(h)
    marker:SetPoint("LEFT", self, "LEFT", width * 0.75, 0)
end)

-- ---------- Resize handles ----------
local function createHandle(anchorPoint, xOffset)
    local h = CreateFrame("Button", nil, tickBar)
    h:SetSize(12, 12)
    h:SetPoint(anchorPoint, tickBar, anchorPoint, xOffset, 0)
    h:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
    h:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Highlight")
    h:SetPushedTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")
    if h:GetNormalTexture() then
        h:GetNormalTexture():SetVertexColor(0.4, 0.4, 0.4)  -- darker default
    end

    h:SetScript("OnEnter", function(self)
        self:GetParent():SetAlpha(1)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Click & drag to resize", 1,1,1)
        GameTooltip:Show()
    end)
    h:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        self:GetParent():SetAlpha(0.6)
    end)

    h:RegisterForDrag("LeftButton")
    -- OnDragStart/OnDragStop will be set after rightHandle is created for hover logic
    return h
end

-- single resize handle (bottom‑right) for width/height
local rightHandle = createHandle("BOTTOMRIGHT", -2)

-- Default invisible but clickable
rightHandle:SetAlpha(0)

local function showHandle()
    rightHandle:SetAlpha(1)
end
local function hideHandle()
    -- only hide if neither bar nor handle is being hovered
    if not tickBar:IsMouseOver() and not rightHandle:IsMouseOver() then
        rightHandle:SetAlpha(0)
    end
end

tickBar:HookScript("OnEnter", showHandle)
tickBar:HookScript("OnLeave", hideHandle)
rightHandle:HookScript("OnLeave", hideHandle)

rightHandle:SetScript("OnDragStart", function(self)
    showHandle()
    if tickBar.StartSizing then
        tickBar:StartSizing("BOTTOMRIGHT")
    end
end)
rightHandle:SetScript("OnDragStop", function(self)
    if tickBar.StopMovingOrSizing then
        tickBar:StopMovingOrSizing()
    end
    if DWT_Settings then
        local w = tickBar:GetWidth()
        local hgt = tickBar:GetHeight()
        -- Clamp minimum height to 8 px, no maximum
        if hgt < 8 then
            hgt = 8
            tickBar:SetHeight(8)
        end
        DWT_Settings.width  = w
        DWT_Settings.height = hgt
    end
    -- reposition / resize marker
    marker:ClearAllPoints()
    marker:SetHeight(tickBar:GetHeight())
    marker:SetPoint("LEFT", tickBar, "LEFT", tickBar:GetWidth() * 0.75, 0)
    hideHandle()
end)

tickBar:Hide()

local comboPulse = comboLabel:CreateAnimationGroup()
local pulse = comboPulse:CreateAnimation("Scale")
pulse:SetScale(1.5, 1.5)
pulse:SetDuration(0.1)
pulse:SetOrder(1)

local shrink = comboPulse:CreateAnimation("Scale")
shrink:SetScale(0.67, 0.67)
shrink:SetDuration(0.1)
shrink:SetOrder(2)

local normalize = comboPulse:CreateAnimation("Scale")
normalize:SetScale(1.0, 1.0)
normalize:SetDuration(0.1)
normalize:SetOrder(3)

f:SetScript("OnUpdate", function(_, elapsed)
    local currentMana, maxMana = ReadMana()
    if not currentMana or (currentMana >= maxMana and not DWT_Settings.showAtFullMana) then
        tickBar:Hide()
        return
    end
    tickBar:Show()
    
    local now = GetTime()
    local diff = now - lastTick
    while diff >= tickInterval do
        diff = diff - tickInterval   
    end
    if comboCount > 0 and now - lastComboTickTime > tickInterval + 0.25 then
        comboCount = 0
        comboLabel:SetText("")
    end
    
    tickBar:SetValue(diff)

    local newLabelText = string.format("%.2f", tickInterval - diff)
    if newLabelText ~= lastLabelText then
        label:SetText(newLabelText)
        lastLabelText = newLabelText
    end
    
    local colorCode
    if tickInterval - diff < 0.25 then
        colorCode = "green"
    elseif tickInterval - diff < 0.50 then
        colorCode = "yellow"
    else
        colorCode = "blue"
    end

    if colorCode ~= lastBarColor then
        lastBarColor = colorCode
        if colorCode == "green" then
            tickBar:SetStatusBarColor(0.6, 1.0, 0.6)
        elseif colorCode == "yellow" then
            tickBar:SetStatusBarColor(1.0, 1.0, 0.6)
        else
            tickBar:SetStatusBarColor(0.6, 0.8, 1.0)
        end
    end
end)

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UNIT_POWER_UPDATE")
f:RegisterEvent("PLAYER_REGEN_ENABLED")   
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")   

local function ResetTracking()
    f.lastMana = nil
    prevTickTime = nil
    lastPassiveSync = 0
    sampleWindow = {}
    comboCount = 0
    comboLabel:SetText("")
    comboPulse:Stop()
    lastTick = GetTime()
end

f:SetScript("OnEvent", function(_, event, arg, powerType)
    if event == "PLAYER_LOGIN" then

        if DWT_Settings.pos then
            local point, x, y = unpack(DWT_Settings.pos)
            tickBar:ClearAllPoints()
            tickBar:SetPoint(point, UIParent, point, x, y)
        else
            tickBar:ClearAllPoints()
            tickBar:SetPoint("CENTER")
        end
        -- apply saved width if exists
        if DWT_Settings.width then
            tickBar:SetWidth(DWT_Settings.width)
        end
        if DWT_Settings.height then
            tickBar:SetHeight(DWT_Settings.height)
        end
        tickBar:SetAlpha(0.6)  -- semi-transparent until hover
        C_Timer.After(0.1, function()
            local width = tickBar:GetWidth()
            marker:SetPoint("LEFT", tickBar, "LEFT", width * 0.75, 0)
        end)
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        ResetTracking()
        tickBar:Hide()
    elseif event == "UNIT_POWER_UPDATE" and arg == "player" and powerType == "MANA" then
        local currentMana, maxMana = ReadMana()
        if not currentMana then
            ResetTracking()
            tickBar:Hide()
            return
        end
        local previousMana = f.lastMana or currentMana
        local drinking = IsDrinking()
        local now = GetTime()
        
        local gap = now - lastTick

        if (not drinking) and currentMana > previousMana and currentMana < maxMana then
            if gap >= tickInterval*0.9 and gap <= tickInterval*1.1 then
                if now - lastPassiveSync > PASSIVE_COOLDOWN then
                    lastTick = now                
                    lastPassiveSync = now
                end
            end
        end

        local delta = 0
        local manaGain = currentMana - previousMana
        if currentMana > previousMana then
            if prevTickTime then
                delta = now - prevTickTime
            end

            if delta > 1.5 and delta < 2.5 and manaGain < MAX_SAMPLE_GAIN and prevTickTime then
                table.insert(sampleWindow, delta)
                if #sampleWindow > SAMPLE_SIZE then
                    table.remove(sampleWindow, 1)
                end
                local sorted = { unpack(sampleWindow) }
                table.sort(sorted)
                local median = sorted[ math.ceil(#sorted / 2) ]
                if math.abs(median - tickInterval) > 0.03 then
                    tickInterval = median
                    tickBar:SetMinMaxValues(0, tickInterval)
                end
            end

            if delta > 1.5 and delta < 2.5 then
                lastTick = now
            end

            if drinking then
                comboCount = comboCount + 1
                lastComboTickTime = now
                comboLabel:SetText("Combo: " .. comboCount)
                if comboPulse:IsPlaying() then comboPulse:Stop() end
                comboPulse:Play()
            else
                comboCount = 0
                comboLabel:SetText("")
            end

            prevTickTime = now
        end
        f.lastMana = currentMana
    end
end)

---------------------------------------------------------------------------
-- Slash command:  /dwt full   → toggles showing the bar at 100 % mana
---------------------------------------------------------------------------
SLASH_DWT1 = "/dwt"
SlashCmdList["DWT"] = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")
    if msg == "full" or msg == "showfull" then
        DWT_Settings.showAtFullMana = not DWT_Settings.showAtFullMana
        print(addonName .. ": Show bar at full mana is now " ..
              (DWT_Settings.showAtFullMana and "ON" or "OFF"))
    else
        print("DrinkWalkTimer commands:")
        print("  /dwt full   - toggle showing the bar at 100% mana")
    end
end
