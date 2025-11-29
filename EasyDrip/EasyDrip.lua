local ADDON, _ = ...
local PREFIX = "|cff33ff99EasyDrip:|r "

-- inventory slots to track
local SLOT_IDS = {
  INVSLOT_HEAD,   INVSLOT_NECK,    INVSLOT_SHOULDER, INVSLOT_BODY,   INVSLOT_CHEST,
  INVSLOT_WAIST,  INVSLOT_LEGS,    INVSLOT_FEET,     INVSLOT_WRIST,  INVSLOT_HAND,
  INVSLOT_FINGER1,INVSLOT_FINGER2, INVSLOT_TRINKET1, INVSLOT_TRINKET2,
  INVSLOT_BACK,   INVSLOT_MAINHAND,INVSLOT_OFFHAND,  INVSLOT_RANGED, INVSLOT_TABARD
}

function InitDB()
  GearSaverDB = GearSaverDB or {}
  local charKey = UnitName("player") .. "-" .. GetRealmName()
  GearSaverDB[charKey] = GearSaverDB[charKey] or { profiles = {} }
end

local function GetProfileDB()
  local charKey = UnitName("player") .. "-" .. GetRealmName()
  return GearSaverDB[charKey].profiles
end

local function SaveSet(name)
  InitDB()
  local set = {}
  for _, slot in ipairs(SLOT_IDS) do
    local itemID = GetInventoryItemID("player", slot)
    if itemID then
      set[slot] = itemID
    end
  end
  GetProfileDB()[name] = set
  print(PREFIX.."saved profile |cff00ff00"..name.."|r.")
end


-- put cursor item into the last available slot of a *general* bag (family 0);
-- totally ignores specialty bags like soul shard pouches
local function PutItemInLastEmptySlot()
  for bag = NUM_BAG_SLOTS, 0, -1 do
    local inventoryID = C_Container.ContainerIDToInventoryID(bag)       -- slot holding the bag itself
    local bagItemID   = GetInventoryItemID("player", inventoryID)
    if not bagItemID or GetItemFamily(bagItemID) == 0 then              -- only scan general‑purpose bags
      local slots = C_Container.GetContainerNumSlots(bag)
      for slot = slots, 1, -1 do
        if not C_Container.GetContainerItemID(bag, slot) then
          C_Container.PickupContainerItem(bag, slot)
          if not GetCursorInfo() then
            return true
          end
        end
      end
    end
  end
  return false
end

local function EquipSet(name)
  InitDB()
  local set = GetProfileDB()[name]
  if not set then
    print(PREFIX.."no profile named '"..name.."'.")
    return
  end

  for _, slot in ipairs(SLOT_IDS) do
    local wanted = set[slot]                    -- itemID or nil
    local current = GetInventoryItemID("player", slot)

    if wanted and current ~= wanted then        -- need to equip a specific item
      EquipItemByName(wanted, slot)
    elseif not wanted and current then          -- slot should be empty, so unequip
      PickupInventoryItem(slot)                 -- pick up the current item
      if not PutItemInLastEmptySlot() then      -- try to stash in last free slot
        print(PREFIX.."bags are full!")         -- cursor will keep the item
      end
    end
  end

  print(PREFIX.."equipped profile |cff00ff00"..name.."|r.")
  -- Post‑check (after a short delay) to verify items actually equipped
  C_Timer.After(1, function()
    local swapIssues = false
    for _, slot in ipairs(SLOT_IDS) do
      local expected = set[slot]
      if expected and GetInventoryItemID("player", slot) ~= expected then
        swapIssues = true
        break
      end
    end
    if swapIssues then
      if UnitAffectingCombat("player") then
        print(PREFIX.."|cffff3333IN COMBAT|r — some items may not have swapped.")
      else
        print(PREFIX.."warning: some items could not be equipped (missing in bags, locked, or on cooldown).")
      end
    end
  end)
end

local function ListSets()
  InitDB()
  print(PREFIX.."saved profiles:")
  for n in pairs(GetProfileDB()) do
    print("  • "..n)
  end
end

-- Slash‑command handler (supports /ed and legacy /gs)
local function EasyDripSlash(msg)
  local cmd, arg = msg:match("^(%S*)%s*(.-)$")
  cmd = cmd:lower()
  if cmd == "save"  and arg ~= "" then
    SaveSet(arg)
  elseif cmd == "equip" and arg ~= "" then
    EquipSet(arg)
  elseif cmd == "list" or cmd == "" then
    ListSets()
  else
    print(PREFIX.."usage: /ed save <name> | equip <name> | list")
  end
end

-- Primary slash commands
SLASH_EASYDRIP1, SLASH_EASYDRIP2 = "/ed", "/easydrip"
SlashCmdList.EASYDRIP = EasyDripSlash

-- Legacy compatibility for old macros (/gs, /gearsaver)
SLASH_GEARSAVER1, SLASH_GEARSAVER2 = "/gs", "/gearsaver"
SlashCmdList.GEARSAVER = EasyDripSlash
