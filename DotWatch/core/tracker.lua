local lastTargetGUID = nil


function SetupTracker(frame)
  frame.healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
  frame.healthBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
  frame.healthBar:SetHeight(frame.iconSize / 5)

  frame.powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, -2)
  frame.powerBar:SetPoint("TOPRIGHT", frame.healthBar, "BOTTOMRIGHT", 0, -2)
  frame.powerBar:SetHeight(frame.iconSize / 6)

  frame.buffText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.buffText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
  frame.buffText:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
  frame.buffText:SetJustifyH("RIGHT")
  frame.buffText:SetText("")
  frame.buffText:SetTextColor(1, 0, 0, 1)

  local function updateDots()
    local unit = "target"
    if UnitExists(unit) and not UnitIsFriend("player", unit) then
      lastTargetGUID = UnitGUID(unit)
    end

    local currentUnit = nil
    for _, u in ipairs({ "target", "focus", "mouseover" }) do
      if UnitExists(u) and UnitGUID(u) == lastTargetGUID and not UnitIsFriend("player", u) then
          currentUnit = u
        break
      end
    end

    if not currentUnit then
      frame:Hide()
      return
    end

    frame:Show()
    local health, healthMax = UnitHealth(currentUnit), UnitHealthMax(currentUnit)
    frame.healthBar:SetMinMaxValues(0, healthMax)
    frame.healthBar:SetValue(health)

    if frame.healthText then
      frame.healthText:SetText(string.format("%d", health))
      frame.healthText:SetDrawLayer("OVERLAY", 7)
    end

    local power, powerMax = UnitPower(currentUnit), UnitPowerMax(currentUnit)
    local _, powerTypeToken = UnitPowerType(currentUnit)
    local color = PowerColors[powerTypeToken] or { r = 0.8, g = 0.8, b = 0.8 }

    frame.powerBar:SetMinMaxValues(0, powerMax)
    frame.powerBar:SetValue(power)
    frame.powerBar:SetStatusBarColor(color.r, color.g, color.b)

    -- Safety: constants not loaded yet? bail gracefully
    if type(DOTS_BY_NAME) ~= "table" or type(DotColorsByName) ~= "table" then
      if frame.buffText then frame.buffText:SetText("[DotWatch] constants not loaded") end
      return
    end

        -- Clear once at start of pass
    for idx = 1, 4 do
      frame.dots[idx]:SetColorTexture(0.2, 0.2, 0.2)
      frame.dots[idx].text:SetText("")
    end

    local slotSet = { [1]=false, [2]=false, [3]=false, [4]=false }

    -- Name-based matches; do not gray-out on misses
    for auraName, slot in pairs(DOTS_BY_NAME) do
      if not slotSet[slot] then
        local name, _, _, _, duration, expirationTime, source = AuraUtil.FindAuraByName(auraName, currentUnit, "HARMFUL")
        if name and source == "player" and duration and expirationTime then
          local timeLeft = expirationTime - GetTime()
          local color = DotColorsByName[auraName] or { r = 0.5, g = 0.5, b = 0.5 }
          frame.dots[slot]:SetColorTexture(color.r, color.g, color.b)
          if timeLeft > 0 and timeLeft < 8 then
            frame.dots[slot].text:SetText(string.format("%.0f", timeLeft))
          end
          slotSet[slot] = true
        end
      end
    end

    -- Fallback: if no specific curse matched, show any player-applied Curse in slot 3
    if not slotSet[3] then
      local i = 1
      while true do
        local name, _, _, debuffType, duration, expirationTime, source = UnitAura(currentUnit, i, "HARMFUL")
        if not name then break end
        if source == "player" and debuffType == "Curse" then
          local timeLeft = (expirationTime and (expirationTime - GetTime())) or 0
          local c = DotColorsByName[name] or DotColorsByName["Curse of Agony"] or { r=0.9, g=0.5, b=0.5 }
          frame.dots[3]:SetColorTexture(c.r, c.g, c.b)
          if timeLeft > 0 and timeLeft < 8 then
            frame.dots[3].text:SetText(string.format("%.0f", timeLeft))
          end
          slotSet[3] = true
          break
        end
        i = i + 1
      end
    end
  end

  local f = CreateFrame("Frame")
  f:RegisterEvent("PLAYER_TARGET_CHANGED")
  f:RegisterEvent("UNIT_AURA")
  f:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_TARGET_CHANGED" 
       or (event == "UNIT_AURA" and (unit == "target" or unit == "focus" or unit == "mouseover")) then
      updateDots()
    end
  end)

  local ticker
  local function startTicker()
    if not ticker then
      ticker = C_Timer.NewTicker(0.2, function()
        updateDots()
      end)
    end
  end

  local function stopTicker()
    if ticker then
      ticker:Cancel()
      ticker = nil
    end
  end

  local combatFrame = CreateFrame("Frame")
  combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
  combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
  combatFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
      startTicker()
    elseif event == "PLAYER_REGEN_ENABLED" then
      stopTicker()
    end
  end)

  updateDots()
end