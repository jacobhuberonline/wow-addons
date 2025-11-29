-- Garr Add Marker – super‑simple version
-- If you have **yourself targeted** and you move the mouse over an attackable NPC,
-- that NPC is given the SKULL raid icon (8) once.

local ICON_ORDER = {8, 7, 6, 5, 4, 3, 2, 1}    -- skull, cross, square, moon, triangle, diamond, circle, star
local marked = {}                               -- guid -> icon

local function firstFreeIcon()
  -- returns the first icon in ICON_ORDER that is not currently in use
  local inUse = {}
  for _, icon in pairs(marked) do inUse[icon] = true end
  for _, icon in ipairs(ICON_ORDER) do
    if not inUse[icon] then return icon end
  end
  return nil   -- all icons taken
end

local function markMouseover()
  -- 1. must be self‑targeted
  if not UnitIsUnit("target", "player") then return end

  -- 2. need a valid hostile mouse‑over
  if not UnitExists("mouseover") or UnitIsDead("mouseover") then return end
  if not UnitCanAttack("player", "mouseover") then return end

  local guid = UnitGUID("mouseover")
  if not guid then return end               -- no GUID yet

  local shift = IsShiftKeyDown()

  -- If Shift is pressed: act only as “unmark”
  if shift then
    local icon = marked[guid]
    if icon then
      SetRaidTarget("mouseover", 0)         -- clear icon
      marked[guid] = nil
      -- icon becomes available automatically because it's no longer in `marked`
      print("|cffff7f00[GAM]|r Removed mark from", UnitName("mouseover"))
    end
    return                                   -- never mark while Shift is held
  end

  -- already processed?
  if marked[guid] then return end

  -- unit already has an icon from someone else?
  if (GetRaidTargetIndex("mouseover") or 0) ~= 0 then return end

  local icon = firstFreeIcon()
  if not icon then return end                      -- no free icons left
  SetRaidTarget("mouseover", icon)
  marked[guid] = icon
  print("|cff00ff00[GAM]|r Marked", UnitName("mouseover"), "with icon", icon)
end

-- event handler
local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(_, ev)
  if ev == "COMBAT_LOG_EVENT_UNFILTERED" then
    local _, subEvent, _, _, _, _, _, dstGUID = CombatLogGetCurrentEventInfo()
    if subEvent == "UNIT_DIED" then
      marked[dstGUID] = nil
    end
    return  -- no further processing needed for this event
  end
  if ev == "UPDATE_MOUSEOVER_UNIT" then
    markMouseover()
  -- elseif ev == "PLAYER_TARGET_CHANGED" then
    -- clear the cache when you re‑select yourself to re‑mark same mobs if needed
    -- if UnitIsUnit("target", "player") then
    --   wipe(marked)
    -- end
  end
end)

print("|cff00ff00[GarrAddMarker]|r loaded → Target yourself and mouse‑over enemies to mark (icons: skull, cross, square, moon, triangle, diamond, circle, star). Hold SHIFT while hovering to clear.")
f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")