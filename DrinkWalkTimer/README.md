# 📜 Drink Walk Timer

## Forever compatibility preview — 1.6.0

Targets WoW Forever 1.60.1 (Interface 16001). Uses the modern
`C_UnitAuras.GetBuffDataByIndex` API on Forever and retains `UnitBuff` for Classic.
Mana and aura tracking runs out of combat only. Restricted mana values hide the
bar; restricted aura data is skipped. Combat transitions clear tracking samples.

### Install the Forever ZIP

1. Exit WoW. Extract `DrinkWalkTimer-1.6.0-Forever-beta.zip`.
2. Copy its `DrinkWalkTimer` folder into your Forever client's `Interface/AddOns`
   folder. The resulting path must be `Interface/AddOns/DrinkWalkTimer/DrinkWalkTimer.toc`.
3. Start WoW and enable Drink Walk Timer. Use a character with mana, spend some
   mana, leave combat, then drink and watch several regeneration ticks.
4. Hover the bar to move it or use its bottom-right resize handle.
   `/dwt full` toggles visibility at full mana.

The repository's base TOC declares Forever Interface 16001 and Classic Interface
11507 so the automatic packager can identify both supported versions.

### Validation and limits

Lua 5.1 mock tests cover loading, modern and legacy aura APIs, mana ticks, combat
transitions, full mana, non-mana characters, death, and restricted mana/aura data.
No in-game Forever test has been performed. This is a preliminary compatibility
beta published through GitHub Actions. Confirm the tick cadence in the game before
relying on the countdown: it predicts an approximately two-second cycle and
cannot guarantee Forever's server regeneration or drink-walking mechanics.
Drink detection still matches the English buff name containing `drink`.

In-game checks: enable Lua errors with `/console scriptErrors 1`, drink while
below full mana, enter/leave combat, resize/move the bar, toggle `/dwt full`,
then `/reload` and confirm the saved size/position and option persist.

API reference: [Forever client UI source](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated).

---

Maximum mana, minimum downtime.

![image](https://github.com/user-attachments/assets/5cd15c23-958f-4013-9ddc-cda1e6ec88a3)

**Drink Walk Timer** tracks the hidden server mana‑tick so you know exactly when to sit, sip, and sprint. Perfect for healers and casters who want to grab every drop of mana without standing still.

***

## ⚙️ Key Features

*   **Live Tick Bar** – Countdown auto‑aligns to the real server heartbeat (≈ 2 s).
*   **Adaptive Sync** – Learns the precise tick interval from _both_ drink and natural mana ticks—no manual reset.
*   **Combo Counter** – Pulses each consecutive drink‑tick you nail.
*   **Smart Hide** – Vanishes in combat, at full mana, or while dead.
*   **Yellow “Sit Now” Marker** – Vertical cue shows the perfect sit window.
*   **Lightweight, Zero Setup** – Drop it in and go.

***

## 🚀 How to Use

1.  **Install** and reload.
2.  When the bar hits yellow, **sit & drink**.
3.  When it hits green (tick!), **run**. Repeat.

***

## ✨ Ideal For

*   Dungeon speed‑clear crews
*   Hardcore grinders / speed‑levelers
*   Anyone who hates wasting drink time 🍻

***

Made with ❤️ + 💧 by JacobHuber

