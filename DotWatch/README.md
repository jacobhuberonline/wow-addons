# DotWatch

**DotWatch** is a minimalist World of Warcraft addon for tracking your DoTs (Damage over Time spells) on your last targeted enemy. Built for Affliction Warlocks in WoW Classic, it provides a clean visual display to keep you informed and efficient in combat.

<img width="1200" alt="DotWatch UI display in game" src="https://github.com/user-attachments/assets/4a849518-f87a-44d0-817d-f39ac21cb8cf" />

---

## ✨ Features

- Tracks DoTs **you** cast:
  - Siphon Life
  - Corruption
  - Curse of Agony
  - Immolate
- Only shows the last valid non-friendly target (even if deselected)
- Shows countdown timers for DoTs with less than 8 seconds left
- Displays enemy health and mana/rage/energy bars
- Clean, centered UI with pastel color-coded DoTs
- Performance-optimized: updates only while in combat

---

## 📦 Installation

- Download or clone this repo:

  ```bash
  git clone https://github.com/yourusername/DotWatch.git
  ```

- Copy the folder into your WoW Classic addons directory:

  ```
  World of Warcraft/_classic_era_/Interface/AddOns/
  ```

- Restart WoW or run `/reload` in-game.

---

## 🔧 File Structure

```
DotWatch/
├── DotWatch.toc             # Addon metadata
├── DotWatch.lua             # Entry point
├── constants/
│   └── spells.lua           # Spell IDs and DoT colors
├── core/
│   └── tracker.lua          # Aura tracking logic
├── ui/
│   └── frame.lua            # Frame layout and visual elements
```

---

## 🛠️ Development Notes

- Written in Lua for WoW Classic Era
- All updates occur via `C_Timer.NewTicker()` **only in combat**
- DoTs are tracked using `AuraUtil.FindAuraByName` and filtered by source (`"player"` only)

---

## 📜 License

MIT License — do whatever you want, just don't claim you wrote it all yourself 😄

---

## 💬 Feedback

Pull requests and issues are welcome. Feel free to fork and enhance — or let me know what you build with it!
