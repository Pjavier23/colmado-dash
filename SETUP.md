# 🛵 Colmado Dash — Setup Guide

**Dominican Republic retro arcade courier game built with SpriteKit**

---

## 🚀 Quick Start

```bash
git clone https://github.com/Pjavier23/colmado-dash.git
```

1. Open `ColmadoDash.xcodeproj` in **Xcode 15+**
2. Go to **Signing & Capabilities** → set your Apple Development Team
3. Select your iPhone as the build target
4. Press **▶️ Run** (`Cmd+R`)

---

## 🎮 How to Play

### Controls
- **Left thumb** — Virtual joystick (drag to move)
- **Right thumb** — Fire button (throw weapon)
- **Weapon selector** — ◀ ▶ buttons above fire

### Delivery Loop
1. Pick a mission from the Mission Select screen
2. Navigate to the glowing **pickup marker** (colmado)
3. Drive to the **destination** (🏁 marker)
4. Collect your cash 💵

### Weapons
| Emoji | Name | Effect |
|-------|------|--------|
| 🍌 | Plátano | Boomerang — curves back |
| 🥚 | Huevo | Straight shot + slime pool |
| 🥩 | Salami | Arc grenade + explosion |
| 💨 | Peo | Freeze cloud (3 seconds) |

### Power-ups (pick up on road)
| Emoji | Name | Effect |
|-------|------|--------|
| 🍺 | Presidente | Speed boost + 3s invincibility |
| 🫕 | Mangú | +1 heart |
| ☕ | Café | Rapid fire (15s) |

---

## 🗺️ Missions

| Mission | Route | Reward | Difficulty |
|---------|-------|--------|------------|
| #1 | Colmado La Palma → Calle El Conde | $150 | FÁCIL |
| #2 | Colmado El Rey → Zona Colonial | $300 | MEDIO |
| #3 | Ferretería La Fe → Los Mina | $500 | DIFÍCIL |
| #4 | Colmado Don Cheo → Villa Juana | $400 | MEDIO |
| #5 | Banca Los Primos → Naco | $600 | DIFÍCIL |

---

## 🚗 Vehicles (unlock in Garage)

| Vehicle | Price | Speed | Notes |
|---------|-------|-------|-------|
| Bicicleta | FREE | ⭐ | Starting vehicle |
| Moto | $500 | ⭐⭐⭐ | Best value |
| Carro | $2,000 | ⭐⭐⭐⭐ | Good defense |
| Concho Taxi | $4,000 | ⭐⭐⭐⭐ | Top capacity |

---

## 🛒 Shop Items

| Item | Price | Effect |
|------|-------|--------|
| 🍺 Presidente | $150 | Speed boost + invincibility |
| 🫕 Mangú | $200 | +1 extra life |
| ☕ Café | $80 | Rapid fire mode |
| ⛑️ Casco | $300 | Extra defense |
| 🥚 Huevo weapon | $100 | Unlock slime weapon |
| 🥩 Salami weapon | $250 | Unlock grenade |
| 💨 Peo weapon | $180 | Unlock freeze cloud |

---

## 🏗️ Project Structure

```
colmado-dash/
├── ColmadoDash.xcodeproj/
│   └── project.pbxproj         # Xcode project (SpriteKit + AVFoundation)
└── ColmadoDash/
    ├── ColmadoDashApp.swift     # SwiftUI entry → GameViewController
    ├── GameViewController.swift # SKView host
    ├── Info.plist
    ├── Scenes/
    │   ├── MenuScene.swift      # Title screen + scrolling city
    │   ├── MissionSelectScene.swift
    │   ├── GameScene.swift      # Main gameplay (top-down)
    │   ├── GarageScene.swift    # Vehicle upgrades
    │   └── ShopScene.swift      # Power-up shop
    ├── Game/
    │   ├── Player.swift         # Vehicle node + physics
    │   ├── Enemy.swift          # Saboteur / cop / swervy car
    │   ├── Weapon.swift         # Projectiles (platano/huevo/salami/fart)
    │   ├── Delivery.swift       # Mission pickup/dropoff logic
    │   ├── GameState.swift      # Data + UserDefaults persistence
    │   └── HUD.swift            # Virtual joystick + UI overlay
    └── Utils/
        ├── SpriteFactory.swift  # All sprites drawn in code (no assets!)
        └── SoundManager.swift   # Haptic feedback (works without audio files)
```

---

## 🎨 Art Style

All sprites are **drawn in code** using `SKShapeNode` + `SKLabelNode`. No image assets needed.

- 🟠 Player = orange rectangle vehicle silhouette
- 🔴 Enemies = red humanoids or cars
- 🔵 Cops = blue car with flashing lights
- 🏙️ Buildings = colorful rectangles with windows + DR business names
- 🌴 Palm trees = programmatic path shapes

---

## Tech Stack

- **Swift 5.9** + **SpriteKit**
- **iOS 16+** deployment target
- Physics via `SKPhysicsBody` + `SKPhysicsContactDelegate`
- Persistence via `UserDefaults`
- Haptics via `UIImpactFeedbackGenerator`
- No third-party dependencies

---

*Hecho con ❤️ en la República Dominicana 🇩🇴*
