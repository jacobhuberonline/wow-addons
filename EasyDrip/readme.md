## 🧢 EasyDrip – WoW Classic Gear Set Manager

**EasyDrip** is a lightweight, no-frills addon for **saving and equipping gear sets** in _World of Warcraft Classic_. It lets players quickly switch between predefined equipment profiles with simple slash commands—perfect for swapping between PvE, PvP, gathering, or RP outfits.

To streamline gear swaps even further, **EasyDrip pairs perfectly with macros**, allowing one-click equipment changes right from your action bar.

---

### ✨ Features

- **Save your current gear** to a named profile  
  `/ed save <name>`
- **Equip any saved gear set** instantly  
  `/ed equip <name>`
- **Auto-unequips missing items** if no item is assigned to a slot
- **Fallback bag management**: moves unequipped items into general-purpose bags (ignores specialty bags like soul pouches)
- **List all saved profiles**  
  `/ed list`

---

### 🧠 How It Works

- Tracks all relevant gear slots using WoW’s inventory API
- Uses a simple profile system stored in `GearSaverDB`
- Swaps gear based on item IDs, making it efficient and fast
- Runs via basic slash commands for maximum compatibility

---

### 🔧 Example Commands

```lua
/ed save pvp
/ed equip gathering
/ed list
```

---

### 📦 Ideal For:

- Hardcore or RP players who want distinct outfits
- PvE/PvP mains who frequently change builds
- Players without bulky UI addons
