# NullVector — Game Manual

> **Target platform:** Processing (Java mode)

---

## 1) Quick Start

1. **Install Processing** Go to the [Processing website](https://processing.org/download)
2. **Open the project**: Double‑click the `.pde` file, or in Processing go to **File → Open…** and select your sketch.  
3. **Run**: Press the **Run** button (▶) or hit **Ctrl+R** (**Cmd+R** on macOS).  
4. **Play** using the controls in the next section.

---

## 2) Open, Build & Run

1. Ensure the sketch folder name matches the main `.pde` file name (Processing convention).  
2. Put any images/sounds into a `data/` folder next to your `.pde` files if the project uses assets.  
3. Open the sketch in Processing and click **Run** (▶).

If you see “**The file … is missing**”, confirm assets are inside `data/` and paths are correct.

---

## 3) Controls

- **Movement**: `W` `A` `S` `D`  
- **Jump**: `Space`  
- **Attack**: **Left mouse button** (`Mouse1`) — throw rocks  
- **Pause**: `P`  
- **Debug view**: `B`

---

## 4) Objectives

- **Win**: Defeat **all enemies** (Zorp and minions).  
- **Lose**: You fall off the platform **or** your health reaches **0**.

A GUI displays **player health** and **boss health** (when Zorp is present). Characters briefly **blink** on taking damage.

---

## 5) Core Mechanics

- **Gravity‑Affected Projectiles**: Your rocks follow an arc. Aim above distant targets.  
- **Bounce Damage**: Rocks/balls that **bounce** deal **half damage** on their next hit.  
- **Friendly Fire**: Enemies can damage each other, but for **reduced damage** compared to hitting you.  
- **Smart Enemies**: Enemies path‑find towards you and attack when in range. If you’re too far, they may **idle/rest**.  
- **Boss Phases**: Damaging Zorp below **50% health** triggers **Phase 2** with increased stats and new behaviors.

---

## 6) Characters

### Player
- Throws **rocks** affected by gravity.  
- Can take damage from enemy attacks.

### Enemies

#### Zapper
- **Attack**: Fires a **zap/laser** for **½ heart** damage.  
- **Behavior**:  
  - Stops to attack when in range; may **aggress/close distance** while attacking.  
  - Moves toward you when out of range.  
  - Can **jump across platforms** to reach you.

#### Dropper
- **Attack**: Drops a **heavy ball** directly above you for **1 heart**.  
- **Behavior**:  
  - **Flies** toward you and **hovers** vertically when near.  
  - If the ball hits the ground first, stepping on it deals **½ heart**.

#### Zorp (Boss)
- **Attacks**:  
  - **Red plasma**: **½ heart**, rapid fire at short range.  
  - **Blue plasma** (Phase 2): **1 heart**, faster projectiles.  
- **Behavior**:  
  - **Flies** aggressively; **hovers** when near.  
  - Stops to unleash rapid **red plasma** if in short range.  
  - Below **50% HP**, enters **Phase 2**: higher **attack speed**, **range**, and **damage**; switches to **blue plasma**.  
  - In Phase 2, can **glitch/teleport** near you (especially if you hide behind walls).  
- **UI**: Boss health bar appears at the bottom of the screen.

---

## 8) Tips & Strategy

- **Lead your shots**: Aim higher and a bit ahead for moving targets.  
- **Exploit friendly fire**: Kite enemies so they damage each other.  
- **Vs. Zapper**: Use cover; bait them into stopping to shoot, then peek and punish.  
- **Vs. Dropper**: Keep moving laterally; don’t stand under its shadow.  
- **Vs. Zorp (Phase 2)**: Keep **mobile and unpredictable**; expect **teleports**. Create distance after each dodge.

---

## 9) Troubleshooting

- **Sketch won’t start**: Confirm **Java mode** is active and you’re using **Processing 4**.  
- **Missing assets**: Ensure required files are in the `data/` folder with correct filenames.  
- **Performance issues**: Close background apps; disable debug view (`B`) while playing.  
- **Input not responding**: Click the game window once to focus before pressing keys.

---

## 10) Credits & License

- **Author(s)**: XiniDev  
- **Art/Audio**: XiniDev  
- **License**: MIT License

---

**Have fun and good luck defeating Zorp and the minions!**
