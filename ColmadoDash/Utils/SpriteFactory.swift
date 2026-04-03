// SpriteFactory.swift — Colmado Dash
// 8-bit arcade visual upgrade: pixel art sprites, NES color palette
// All sprites drawn programmatically. No external image assets needed.

import SpriteKit

// MARK: - NES/Arcade Color Palette

struct Colors {
    // Sky / environment
    static let skyBlue    = SKColor(red: 0.39, green: 0.69, blue: 1.0,  alpha: 1) // #63B0FF
    static let darkBlue   = SKColor(red: 0.00, green: 0.11, blue: 0.50, alpha: 1) // #001C80
    static let grassGreen = SKColor(red: 0.24, green: 0.60, blue: 0.08, alpha: 1) // #3D9915
    static let darkGreen  = SKColor(red: 0.13, green: 0.37, blue: 0.04, alpha: 1) // #215F0A

    // Road
    static let roadGray   = SKColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1) // #4A4A4A
    static let roadDark   = SKColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1) // #333333
    static let sidewalkTan = SKColor(red: 0.73, green: 0.67, blue: 0.53, alpha: 1) // #BAAB87
    static let lineYellow = SKColor(red: 1.0,  green: 0.86, blue: 0.0,  alpha: 1) // #FFDB00

    // Buildings — bold arcade colors
    static let red    = SKColor(red: 0.87, green: 0.16, blue: 0.16, alpha: 1) // #DE2929
    static let blue   = SKColor(red: 0.16, green: 0.35, blue: 0.87, alpha: 1) // #2959DE
    static let purple = SKColor(red: 0.55, green: 0.16, blue: 0.87, alpha: 1) // #8C29DE
    static let orange = SKColor(red: 0.95, green: 0.50, blue: 0.05, alpha: 1) // #F2800D
    static let teal   = SKColor(red: 0.08, green: 0.63, blue: 0.63, alpha: 1) // #15A1A1

    // Player / enemies
    static let playerOrange = SKColor(red: 1.0,  green: 0.45, blue: 0.09, alpha: 1) // #FF7317
    static let enemyRed     = SKColor(red: 0.90, green: 0.10, blue: 0.10, alpha: 1)
    static let copBlue      = SKColor(red: 0.10, green: 0.20, blue: 0.80, alpha: 1)
    static let skinTone     = SKColor(red: 1.0,  green: 0.80, blue: 0.60, alpha: 1) // #FFCC99

    // UI
    static let hudBlack = SKColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 0.92)
    static let gold     = SKColor(red: 1.0,  green: 0.84, blue: 0.0,  alpha: 1)    // #FFD700
    static let white    = SKColor.white
    static let black    = SKColor.black

    // Legacy aliases for compatibility
    static let road     = roadGray
    static let sidewalk = sidewalkTan
    static let player   = playerOrange
    static let enemy    = enemyRed
    static let cop      = copBlue
    static let hudBG    = hudBlack
    static let yellow   = lineYellow

    static let buildings: [SKColor] = [red, blue, purple, orange, teal]
}

// MARK: - SpriteFactory

enum SpriteFactory {

    // MARK: - Player Vehicles (8-bit pixel art style, top-down)

    static func makePlayer(type: VehicleType) -> SKNode {
        switch type {
        case .bicycle: return makeBicycle()
        case .moped:   return makeMoped()
        case .car:     return makeCar()
        case .concho:  return makeConcho()
        }
    }

    /// Bicycle — 24x32 pixel art
    static func makeBicycle() -> SKNode {
        let root = SKNode()

        // Frame: brown horizontal bar
        let frameH = SKShapeNode(rectOf: CGSize(width: 22, height: 5))
        frameH.fillColor = SKColor(red: 0.40, green: 0.22, blue: 0.06, alpha: 1)
        frameH.strokeColor = .black; frameH.lineWidth = 1.5
        frameH.position = CGPoint(x: 0, y: 0)
        root.addChild(frameH)

        // Frame: vertical stem
        let frameV = SKShapeNode(rectOf: CGSize(width: 5, height: 10))
        frameV.fillColor = SKColor(red: 0.40, green: 0.22, blue: 0.06, alpha: 1)
        frameV.strokeColor = .black; frameV.lineWidth = 1.5
        frameV.position = CGPoint(x: 2, y: 5)
        root.addChild(frameV)

        // Wheels — 8x8 squares (pixel art style)
        for x: CGFloat in [-10, 10] {
            let wheel = SKShapeNode(rectOf: CGSize(width: 8, height: 8))
            wheel.fillColor = .black; wheel.strokeColor = .black; wheel.lineWidth = 1
            wheel.position = CGPoint(x: x, y: -3)
            root.addChild(wheel)
            // Hub cap
            let hub = SKShapeNode(rectOf: CGSize(width: 3, height: 3))
            hub.fillColor = SKColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            hub.strokeColor = .clear
            hub.position = CGPoint(x: x, y: -3)
            root.addChild(hub)
        }

        // Rider body (orange)
        let body = SKShapeNode(rectOf: CGSize(width: 12, height: 14))
        body.fillColor = Colors.playerOrange; body.strokeColor = .black; body.lineWidth = 1.5
        body.position = CGPoint(x: 1, y: 11)
        root.addChild(body)

        // Head (skin tone)
        let head = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
        head.fillColor = Colors.skinTone; head.strokeColor = .black; head.lineWidth = 1.5
        head.position = CGPoint(x: 1, y: 21)
        root.addChild(head)

        // Helmet (red)
        let helmet = SKShapeNode(rectOf: CGSize(width: 12, height: 8))
        helmet.fillColor = Colors.red; helmet.strokeColor = .black; helmet.lineWidth = 1.5
        helmet.position = CGPoint(x: 1, y: 27)
        root.addChild(helmet)

        return root
    }

    /// Moped — 32x40 pixels
    static func makeMoped() -> SKNode {
        let root = SKNode()

        // Body — sharp orange rectangle (no corner radius = pixel art)
        let body = SKShapeNode(rectOf: CGSize(width: 28, height: 20))
        body.fillColor = Colors.playerOrange; body.strokeColor = .black; body.lineWidth = 2
        body.position = .zero
        root.addChild(body)

        // Seat — dark brown strip
        let seat = SKShapeNode(rectOf: CGSize(width: 18, height: 5))
        seat.fillColor = SKColor(red: 0.28, green: 0.14, blue: 0.04, alpha: 1)
        seat.strokeColor = .black; seat.lineWidth = 1
        seat.position = CGPoint(x: 2, y: 10)
        root.addChild(seat)

        // Headlight — yellow square 6x6
        let headlight = SKShapeNode(rectOf: CGSize(width: 6, height: 6))
        headlight.fillColor = Colors.lineYellow; headlight.strokeColor = .black; headlight.lineWidth = 1
        headlight.position = CGPoint(x: 14, y: 2)
        root.addChild(headlight)

        // Exhaust — gray tiny rect
        let exhaust = SKShapeNode(rectOf: CGSize(width: 8, height: 4))
        exhaust.fillColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        exhaust.strokeColor = .black; exhaust.lineWidth = 1
        exhaust.position = CGPoint(x: -16, y: -3)
        root.addChild(exhaust)

        // Wheels — black circle with white hubcap
        for x: CGFloat in [-12, 12] {
            let wheel = SKShapeNode(circleOfRadius: 10)
            wheel.fillColor = .black; wheel.strokeColor = .black; wheel.lineWidth = 1.5
            wheel.position = CGPoint(x: x, y: -6)
            root.addChild(wheel)
            let hub = SKShapeNode(circleOfRadius: 4)
            hub.fillColor = .white; hub.strokeColor = .black; hub.lineWidth = 1
            hub.position = CGPoint(x: x, y: -6)
            root.addChild(hub)
        }

        // Rider body
        let riderBody = SKShapeNode(rectOf: CGSize(width: 14, height: 16))
        riderBody.fillColor = Colors.playerOrange; riderBody.strokeColor = .black; riderBody.lineWidth = 1.5
        riderBody.position = CGPoint(x: 2, y: 22)
        root.addChild(riderBody)

        // Rider head (skin)
        let riderHead = SKShapeNode(rectOf: CGSize(width: 12, height: 12))
        riderHead.fillColor = Colors.skinTone; riderHead.strokeColor = .black; riderHead.lineWidth = 1.5
        riderHead.position = CGPoint(x: 2, y: 36)
        root.addChild(riderHead)

        // Helmet (red, 14x10)
        let riderHelmet = SKShapeNode(rectOf: CGSize(width: 14, height: 10))
        riderHelmet.fillColor = Colors.red; riderHelmet.strokeColor = .black; riderHelmet.lineWidth = 1.5
        riderHelmet.position = CGPoint(x: 2, y: 43)
        root.addChild(riderHelmet)

        return root
    }

    /// Car — 44x32 pixels
    static func makeCar() -> SKNode {
        let root = SKNode()

        // Body — sharp rectangle
        let body = SKShapeNode(rectOf: CGSize(width: 44, height: 24))
        body.fillColor = Colors.playerOrange; body.strokeColor = .black; body.lineWidth = 2
        root.addChild(body)

        // Roof — darker
        let roof = SKShapeNode(rectOf: CGSize(width: 28, height: 14))
        roof.fillColor = SKColor(red: 0.75, green: 0.30, blue: 0.02, alpha: 1)
        roof.strokeColor = .black; roof.lineWidth = 1.5
        roof.position = CGPoint(x: 0, y: 12)
        root.addChild(roof)

        // Windows — blue-tinted
        for (xPos, yPos): (CGFloat, CGFloat) in [(-6, 12), (8, 12)] {
            let win = SKShapeNode(rectOf: CGSize(width: 10, height: 8))
            win.fillColor = SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.85)
            win.strokeColor = .black; win.lineWidth = 1
            win.position = CGPoint(x: xPos, y: yPos)
            root.addChild(win)
        }

        // Wheels — black with white hubcap
        for (x, y): (CGFloat, CGFloat) in [(-18, -8), (18, -8), (-18, 8), (18, 8)] {
            let w = SKShapeNode(circleOfRadius: 10)
            w.fillColor = .black; w.strokeColor = .black; w.lineWidth = 2
            w.position = CGPoint(x: x, y: y)
            root.addChild(w)
            let hub = SKShapeNode(circleOfRadius: 4)
            hub.fillColor = .white; hub.strokeColor = .black; hub.lineWidth = 1
            hub.position = CGPoint(x: x, y: y)
            root.addChild(hub)
        }

        // Headlights — yellow 8x6 at front
        for y: CGFloat in [-4, 4] {
            let hl = SKShapeNode(rectOf: CGSize(width: 8, height: 6))
            hl.fillColor = Colors.lineYellow; hl.strokeColor = .black; hl.lineWidth = 1
            hl.position = CGPoint(x: 22, y: y)
            root.addChild(hl)
        }

        // Taillights — red 6x6 at back
        for y: CGFloat in [-4, 4] {
            let tl = SKShapeNode(rectOf: CGSize(width: 6, height: 6))
            tl.fillColor = Colors.red; tl.strokeColor = .black; tl.lineWidth = 1
            tl.position = CGPoint(x: -22, y: y)
            root.addChild(tl)
        }

        return root
    }

    /// Concho (shared taxi) — yellow, 50x28
    static func makeConcho() -> SKNode {
        let root = SKNode()

        // Body
        let body = SKShapeNode(rectOf: CGSize(width: 50, height: 26))
        body.fillColor = Colors.lineYellow; body.strokeColor = .black; body.lineWidth = 2
        root.addChild(body)

        // Red stripe
        let stripe = SKShapeNode(rectOf: CGSize(width: 50, height: 6))
        stripe.fillColor = Colors.red; stripe.strokeColor = .clear
        stripe.position = CGPoint(x: 0, y: 0)
        root.addChild(stripe)

        // Roof
        let roof = SKShapeNode(rectOf: CGSize(width: 30, height: 14))
        roof.fillColor = SKColor(red: 0.90, green: 0.76, blue: 0.0, alpha: 1)
        roof.strokeColor = .black; roof.lineWidth = 1.5
        roof.position = CGPoint(x: 0, y: 13)
        root.addChild(roof)

        // Windows
        for (xPos, yPos): (CGFloat, CGFloat) in [(-6, 13), (8, 13)] {
            let win = SKShapeNode(rectOf: CGSize(width: 10, height: 8))
            win.fillColor = SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.85)
            win.strokeColor = .black; win.lineWidth = 1
            win.position = CGPoint(x: xPos, y: yPos)
            root.addChild(win)
        }

        // Wheels
        for (x, y): (CGFloat, CGFloat) in [(-20, -8), (20, -8), (-20, 8), (20, 8)] {
            let w = SKShapeNode(circleOfRadius: 9)
            w.fillColor = .black; w.strokeColor = .black; w.lineWidth = 2
            w.position = CGPoint(x: x, y: y)
            root.addChild(w)
            let hub = SKShapeNode(circleOfRadius: 3)
            hub.fillColor = .white; hub.strokeColor = .black; hub.lineWidth = 1
            hub.position = CGPoint(x: x, y: y)
            root.addChild(hub)
        }

        return root
    }

    // MARK: - Enemy Sprites

    /// Saboteur — walking enemy
    static func makeEnemy() -> SKNode {
        let root = SKNode()

        // Body — red rectangle 16x20
        let body = SKShapeNode(rectOf: CGSize(width: 16, height: 20))
        body.fillColor = Colors.enemyRed; body.strokeColor = .black; body.lineWidth = 2
        body.position = .zero
        root.addChild(body)

        // Head — skin tone 14x14
        let head = SKShapeNode(rectOf: CGSize(width: 14, height: 14))
        head.fillColor = Colors.skinTone; head.strokeColor = .black; head.lineWidth = 1.5
        head.position = CGPoint(x: 0, y: 17)
        root.addChild(head)

        // Arms — small rectangles
        for x: CGFloat in [-11, 11] {
            let arm = SKShapeNode(rectOf: CGSize(width: 5, height: 12))
            arm.fillColor = Colors.enemyRed; arm.strokeColor = .black; arm.lineWidth = 1
            arm.position = CGPoint(x: x, y: 4)
            root.addChild(arm)
        }

        // Legs — alternating (suggests walking)
        let legL = SKShapeNode(rectOf: CGSize(width: 6, height: 10))
        legL.fillColor = SKColor(red: 0.25, green: 0.15, blue: 0.05, alpha: 1)
        legL.strokeColor = .black; legL.lineWidth = 1
        legL.position = CGPoint(x: -4, y: -13)
        root.addChild(legL)

        let legR = SKShapeNode(rectOf: CGSize(width: 6, height: 10))
        legR.fillColor = SKColor(red: 0.25, green: 0.15, blue: 0.05, alpha: 1)
        legR.strokeColor = .black; legR.lineWidth = 1
        legR.position = CGPoint(x: 4, y: -15) // offset for walking animation look
        root.addChild(legR)

        return root
    }

    /// Enemy car — red version of player car
    static func makeEnemyCar() -> SKNode {
        let root = SKNode()

        let body = SKShapeNode(rectOf: CGSize(width: 44, height: 24))
        body.fillColor = Colors.enemyRed; body.strokeColor = .black; body.lineWidth = 2
        root.addChild(body)

        let roof = SKShapeNode(rectOf: CGSize(width: 28, height: 14))
        roof.fillColor = SKColor(red: 0.65, green: 0.06, blue: 0.06, alpha: 1)
        roof.strokeColor = .black; roof.lineWidth = 1.5
        roof.position = CGPoint(x: 0, y: 12)
        root.addChild(roof)

        for (xPos, yPos): (CGFloat, CGFloat) in [(-6, 12), (8, 12)] {
            let win = SKShapeNode(rectOf: CGSize(width: 10, height: 8))
            win.fillColor = SKColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 0.8)
            win.strokeColor = .black; win.lineWidth = 1
            win.position = CGPoint(x: xPos, y: yPos)
            root.addChild(win)
        }

        for (x, y): (CGFloat, CGFloat) in [(-18, -8), (18, -8), (-18, 8), (18, 8)] {
            let w = SKShapeNode(circleOfRadius: 10)
            w.fillColor = .black; w.strokeColor = .black; w.lineWidth = 2
            w.position = CGPoint(x: x, y: y)
            root.addChild(w)
            let hub = SKShapeNode(circleOfRadius: 4)
            hub.fillColor = .white; hub.strokeColor = .black; hub.lineWidth = 1
            hub.position = CGPoint(x: x, y: y)
            root.addChild(hub)
        }

        return root
    }

    /// Police car — blue with POLICIA label and siren
    static func makeCopCar() -> SKNode {
        let root = SKNode()

        // Body
        let body = SKShapeNode(rectOf: CGSize(width: 44, height: 24))
        body.fillColor = Colors.copBlue; body.strokeColor = .black; body.lineWidth = 2
        root.addChild(body)

        // Roof
        let roof = SKShapeNode(rectOf: CGSize(width: 28, height: 14))
        roof.fillColor = SKColor(red: 0.06, green: 0.12, blue: 0.60, alpha: 1)
        roof.strokeColor = .black; roof.lineWidth = 1.5
        roof.position = CGPoint(x: 0, y: 12)
        root.addChild(roof)

        // POLICIA label
        let label = SKLabelNode(text: "POLICIA")
        label.fontName = "Courier-Bold"; label.fontSize = 7
        label.fontColor = .white; label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        root.addChild(label)

        // White stripe
        let stripe = SKShapeNode(rectOf: CGSize(width: 44, height: 5))
        stripe.fillColor = .white; stripe.strokeColor = .clear
        stripe.position = CGPoint(x: 0, y: -3)
        root.addChild(stripe)

        // Siren light bar
        let sirenBar = SKShapeNode(rectOf: CGSize(width: 20, height: 6))
        sirenBar.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        sirenBar.strokeColor = .black; sirenBar.lineWidth = 1
        sirenBar.position = CGPoint(x: 0, y: 19)
        root.addChild(sirenBar)

        // Red siren light
        let redLight = SKShapeNode(circleOfRadius: 4)
        redLight.fillColor = .red; redLight.strokeColor = .black; redLight.lineWidth = 1
        redLight.position = CGPoint(x: -5, y: 19)
        root.addChild(redLight)

        // Blue siren light
        let blueLight = SKShapeNode(circleOfRadius: 4)
        blueLight.fillColor = SKColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1)
        blueLight.strokeColor = .black; blueLight.lineWidth = 1
        blueLight.position = CGPoint(x: 5, y: 19)
        root.addChild(blueLight)

        // Animate siren flash
        let flashRed = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.3),
            SKAction.colorize(with: SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1), colorBlendFactor: 1, duration: 0.3)
        ])
        let flashBlue = SKAction.sequence([
            SKAction.colorize(with: SKColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1), colorBlendFactor: 1, duration: 0.3),
            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.3)
        ])
        redLight.run(SKAction.repeatForever(flashRed))
        blueLight.run(SKAction.repeatForever(flashBlue))

        // Wheels
        for (x, y): (CGFloat, CGFloat) in [(-18, -8), (18, -8), (-18, 8), (18, 8)] {
            let w = SKShapeNode(circleOfRadius: 10)
            w.fillColor = .black; w.strokeColor = .black; w.lineWidth = 2
            w.position = CGPoint(x: x, y: y)
            root.addChild(w)
            let hub = SKShapeNode(circleOfRadius: 4)
            hub.fillColor = .white; hub.strokeColor = .black; hub.lineWidth = 1
            hub.position = CGPoint(x: x, y: y)
            root.addChild(hub)
        }

        // Headlights
        for y: CGFloat in [-4, 4] {
            let hl = SKShapeNode(rectOf: CGSize(width: 7, height: 5))
            hl.fillColor = Colors.lineYellow; hl.strokeColor = .black; hl.lineWidth = 1
            hl.position = CGPoint(x: 22, y: y)
            root.addChild(hl)
        }

        return root
    }

    // MARK: - Buildings (NES arcade style, side view)

    static func makeBuilding(width: CGFloat, height: CGFloat, label: String, colorIndex: Int) -> SKNode {
        let root = SKNode()
        let color = Colors.buildings[colorIndex % Colors.buildings.count]

        // Base building rectangle with BLACK OUTLINE (lineWidth: 3)
        let bldg = SKShapeNode(rectOf: CGSize(width: width, height: height))
        bldg.fillColor = color; bldg.strokeColor = .black; bldg.lineWidth = 3
        bldg.position = CGPoint(x: 0, y: height / 2)
        root.addChild(bldg)

        // Windows: 2-column grid, yellow filled, black outline
        let cols = max(1, Int(width / 28))
        let rows = max(1, Int(height / 30))
        let winW: CGFloat = 10; let winH: CGFloat = 12
        let colSpacing = (width - 20) / CGFloat(cols)
        let rowSpacing: CGFloat = 26

        for col in 0..<cols {
            for row in 0..<rows {
                let win = SKShapeNode(rectOf: CGSize(width: winW, height: winH))
                // Randomly lit or dark
                win.fillColor = Bool.random()
                    ? SKColor(red: 1.0, green: 0.97, blue: 0.5, alpha: 0.95)
                    : SKColor(red: 0.10, green: 0.10, blue: 0.20, alpha: 0.90)
                win.strokeColor = .black; win.lineWidth = 1.5
                let wx = -width / 2 + 10 + CGFloat(col) * colSpacing + colSpacing / 2
                let wy = -height / 2 + 16 + CGFloat(row) * rowSpacing
                win.position = CGPoint(x: wx, y: wy)
                bldg.addChild(win)
            }
        }

        // Door — brown rectangle at bottom center
        let door = SKShapeNode(rectOf: CGSize(width: max(14, width * 0.18), height: 20))
        door.fillColor = SKColor(red: 0.40, green: 0.22, blue: 0.06, alpha: 1)
        door.strokeColor = .black; door.lineWidth = 2
        door.position = CGPoint(x: 0, y: -height / 2 + 10)
        bldg.addChild(door)

        // Door knob
        let knob = SKShapeNode(circleOfRadius: 2)
        knob.fillColor = Colors.lineYellow; knob.strokeColor = .clear
        knob.position = CGPoint(x: 4, y: -height / 2 + 10)
        bldg.addChild(knob)

        // Sign strip — contrasting color at top
        let signH: CGFloat = 18
        let signColor: SKColor
        switch colorIndex % 5 {
        case 0: signColor = Colors.lineYellow
        case 1: signColor = Colors.orange
        case 2: signColor = Colors.lineYellow
        case 3: signColor = Colors.teal
        default: signColor = Colors.lineYellow
        }
        let sign = SKShapeNode(rectOf: CGSize(width: width, height: signH))
        sign.fillColor = signColor; sign.strokeColor = .black; sign.lineWidth = 2
        sign.position = CGPoint(x: 0, y: height / 2 - signH / 2)
        bldg.addChild(sign)

        // Sign label text
        let lbl = SKLabelNode(text: label)
        lbl.fontName = "Courier-Bold"
        lbl.fontSize = min(9, width / CGFloat(max(label.count, 1)) * 1.3)
        lbl.fontColor = signColor == Colors.lineYellow ? .black : .white
        lbl.verticalAlignmentMode = .center
        lbl.position = CGPoint(x: 0, y: height / 2 - signH / 2)
        bldg.addChild(lbl)

        // Optional: AC unit (gray square on side)
        if Bool.random() && width > 60 {
            let ac = SKShapeNode(rectOf: CGSize(width: 16, height: 12))
            ac.fillColor = SKColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1)
            ac.strokeColor = .black; ac.lineWidth = 1.5
            ac.position = CGPoint(x: width / 2 - 12, y: height / 2 - 40)
            bldg.addChild(ac)
        }

        // Optional: Antenna (thin line on roof)
        if Bool.random() {
            let antBase = SKShapeNode(rectOf: CGSize(width: 3, height: 20))
            antBase.fillColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
            antBase.strokeColor = .black; antBase.lineWidth = 1
            antBase.position = CGPoint(x: CGFloat.random(in: -10...10), y: height / 2 + 10)
            bldg.addChild(antBase)
        }

        return root
    }

    // MARK: - Colmado (pickup/dropoff marker building)

    static func makeColmado(isActive: Bool = false) -> SKNode {
        let root = SKNode()
        let w: CGFloat = 80; let h: CGFloat = 100

        // Main building
        let bldg = SKShapeNode(rectOf: CGSize(width: w, height: h))
        bldg.fillColor = SKColor(red: 0.95, green: 0.75, blue: 0.30, alpha: 1)
        bldg.strokeColor = .black; bldg.lineWidth = 3
        bldg.position = CGPoint(x: 0, y: h / 2)
        root.addChild(bldg)

        // Striped awning/canopy — alternating two colors
        let awningH: CGFloat = 18; let awningY = h - awningH / 2
        let awning = SKNode()
        awning.position = CGPoint(x: 0, y: awningY)
        bldg.addChild(awning)

        let stripeCount = 8
        let stripeW = w / CGFloat(stripeCount)
        for i in 0..<stripeCount {
            let stripe = SKShapeNode(rectOf: CGSize(width: stripeW, height: awningH))
            stripe.fillColor = i % 2 == 0 ? Colors.red : Colors.lineYellow
            stripe.strokeColor = .clear
            stripe.position = CGPoint(x: -w / 2 + CGFloat(i) * stripeW + stripeW / 2, y: 0)
            awning.addChild(stripe)
        }
        // Awning border
        let awningBorder = SKShapeNode(rectOf: CGSize(width: w, height: awningH))
        awningBorder.fillColor = .clear; awningBorder.strokeColor = .black; awningBorder.lineWidth = 2
        awningBorder.position = .zero
        awning.addChild(awningBorder)

        // "COLMADO" sign — neon yellow
        let colSign = SKShapeNode(rectOf: CGSize(width: w - 8, height: 20))
        colSign.fillColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.85)
        colSign.strokeColor = Colors.lineYellow; colSign.lineWidth = 2
        colSign.position = CGPoint(x: 0, y: h / 2 - 34)
        bldg.addChild(colSign)

        let colLbl = SKLabelNode(text: "COLMADO")
        colLbl.fontName = "Courier-Bold"; colLbl.fontSize = 11
        colLbl.fontColor = Colors.lineYellow; colLbl.verticalAlignmentMode = .center
        colLbl.position = CGPoint(x: 0, y: h / 2 - 34)
        bldg.addChild(colLbl)

        // Shelves visible in window area
        let windowArea = SKShapeNode(rectOf: CGSize(width: 60, height: 30))
        windowArea.fillColor = SKColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 0.9)
        windowArea.strokeColor = .black; windowArea.lineWidth = 2
        windowArea.position = CGPoint(x: 0, y: h / 2 - 65)
        bldg.addChild(windowArea)

        // Shelf lines in window
        for sy in [-5, 5] {
            let shelf = SKShapeNode(rectOf: CGSize(width: 55, height: 2))
            shelf.fillColor = SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1)
            shelf.strokeColor = .clear
            shelf.position = CGPoint(x: 0, y: CGFloat(sy))
            windowArea.addChild(shelf)
        }

        // Door
        let door = SKShapeNode(rectOf: CGSize(width: 22, height: 26))
        door.fillColor = SKColor(red: 0.40, green: 0.22, blue: 0.06, alpha: 1)
        door.strokeColor = .black; door.lineWidth = 2
        door.position = CGPoint(x: 0, y: -h / 2 + 13)
        bldg.addChild(door)

        // Blinking "OPEN" indicator when active
        if isActive {
            let openSign = SKShapeNode(rectOf: CGSize(width: 32, height: 14))
            openSign.fillColor = SKColor(red: 0.0, green: 0.7, blue: 0.2, alpha: 1)
            openSign.strokeColor = Colors.lineYellow; openSign.lineWidth = 2
            openSign.position = CGPoint(x: 0, y: h / 2 - 54)
            bldg.addChild(openSign)

            let openLbl = SKLabelNode(text: "OPEN")
            openLbl.fontName = "Courier-Bold"; openLbl.fontSize = 8
            openLbl.fontColor = .white; openLbl.verticalAlignmentMode = .center
            openLbl.position = CGPoint(x: 0, y: h / 2 - 54)
            bldg.addChild(openLbl)

            let blink = SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.4),
                SKAction.fadeOut(withDuration: 0.4)
            ]))
            openSign.run(blink)
            openLbl.run(blink)
        }

        return root
    }

    // MARK: - Weapons (visual upgrades)

    static func makePlatano() -> SKNode {
        let root = SKNode()
        // Curved banana shape using multiple small rects to simulate curve
        let positions: [(CGFloat, CGFloat, CGFloat)] = [
            (-6, -4, 0.3), (-3, -1, 0.2), (0, 2, 0.1), (3, 4, -0.1), (6, 3, -0.3)
        ]
        for (x, y, rot) in positions {
            let seg = SKShapeNode(rectOf: CGSize(width: 6, height: 10))
            seg.fillColor = Colors.lineYellow; seg.strokeColor = .black; seg.lineWidth = 1
            seg.position = CGPoint(x: x, y: y)
            seg.zRotation = rot
            root.addChild(seg)
        }
        return root
    }

    static func makeHuevo() -> SKNode {
        let root = SKNode()
        // White oval — circle with slight squish
        let egg = SKShapeNode(ellipseOf: CGSize(width: 14, height: 18))
        egg.fillColor = .white; egg.strokeColor = .black; egg.lineWidth = 2
        root.addChild(egg)
        return root
    }

    static func makeSalami() -> SKNode {
        let root = SKNode()
        // Dark red cylinder shape
        let body = SKShapeNode(rectOf: CGSize(width: 20, height: 10))
        body.fillColor = SKColor(red: 0.55, green: 0.08, blue: 0.08, alpha: 1)
        body.strokeColor = .black; body.lineWidth = 2
        root.addChild(body)
        // End caps
        for x: CGFloat in [-11, 11] {
            let cap = SKShapeNode(circleOfRadius: 5)
            cap.fillColor = SKColor(red: 0.45, green: 0.06, blue: 0.06, alpha: 1)
            cap.strokeColor = .black; cap.lineWidth = 1
            cap.position = CGPoint(x: x, y: 0)
            root.addChild(cap)
        }
        return root
    }

    static func makePeoCloud() -> SKNode {
        let root = SKNode()
        // Green fuzzy cloud — multiple overlapping circles with slight transparency
        let positions: [(CGFloat, CGFloat, CGFloat)] = [
            (0, 0, 14), (-8, 5, 10), (8, 5, 10), (-5, -6, 9), (5, -6, 9),
            (0, 10, 8), (-12, 0, 8), (12, 0, 8)
        ]
        for (x, y, r) in positions {
            let blob = SKShapeNode(circleOfRadius: r)
            blob.fillColor = SKColor(red: 0.20, green: 0.75, blue: 0.15, alpha: 0.70)
            blob.strokeColor = SKColor(red: 0.10, green: 0.50, blue: 0.05, alpha: 0.5)
            blob.lineWidth = 1
            blob.position = CGPoint(x: x, y: y)
            root.addChild(blob)
        }
        return root
    }

    // MARK: - Palm Tree

    static func makePalmTree(height: CGFloat = 70) -> SKNode {
        let root = SKNode()

        // Trunk — slightly tapered using rectangles
        let trunk = SKShapeNode(rectOf: CGSize(width: 8, height: height))
        trunk.fillColor = SKColor(red: 0.55, green: 0.38, blue: 0.18, alpha: 1)
        trunk.strokeColor = .black; trunk.lineWidth = 1.5
        trunk.position = CGPoint(x: 0, y: height / 2)
        root.addChild(trunk)

        // Leaves — pixel art style (rectangular leaf segments)
        let leafColor = Colors.darkGreen
        let leafAngles: [CGFloat] = [0, 45, 90, 135, 180, 225, 270, 315]
        for angle in leafAngles {
            let leafNode = SKNode()
            leafNode.position = CGPoint(x: 0, y: height)
            leafNode.zRotation = angle * .pi / 180

            let leaf = SKShapeNode(rectOf: CGSize(width: 26, height: 6))
            leaf.fillColor = leafColor; leaf.strokeColor = .black; leaf.lineWidth = 1
            leaf.position = CGPoint(x: 13, y: 0)
            leafNode.addChild(leaf)

            root.addChild(leafNode)
        }

        return root
    }

    // MARK: - Package / Pickup Marker

    static func makePackage() -> SKNode {
        let root = SKNode()

        let box = SKShapeNode(rectOf: CGSize(width: 18, height: 18))
        box.fillColor = SKColor(red: 0.65, green: 0.42, blue: 0.15, alpha: 1)
        box.strokeColor = .black; box.lineWidth = 2
        root.addChild(box)

        // Cross tape strips
        let h = SKShapeNode(rectOf: CGSize(width: 18, height: 4))
        h.fillColor = Colors.lineYellow; h.strokeColor = .clear
        root.addChild(h)
        let v = SKShapeNode(rectOf: CGSize(width: 4, height: 18))
        v.fillColor = Colors.lineYellow; v.strokeColor = .clear
        root.addChild(v)

        return root
    }

    static func makePickupMarker(label: String) -> SKNode {
        let root = SKNode()

        // Arrow — drawn as triangle shape (pixel art down arrow)
        let arrowBody = SKShapeNode(rectOf: CGSize(width: 10, height: 20))
        arrowBody.fillColor = Colors.lineYellow; arrowBody.strokeColor = .black; arrowBody.lineWidth = 2
        arrowBody.position = CGPoint(x: 0, y: 40)
        root.addChild(arrowBody)

        let arrowHead = SKShapeNode()
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: -12, y: 30))
        arrowPath.addLine(to: CGPoint(x: 12, y: 30))
        arrowPath.addLine(to: CGPoint(x: 0, y: 18))
        arrowPath.closeSubpath()
        arrowHead.path = arrowPath
        arrowHead.fillColor = Colors.lineYellow; arrowHead.strokeColor = .black; arrowHead.lineWidth = 2
        root.addChild(arrowHead)

        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 6, duration: 0.5),
            SKAction.moveBy(x: 0, y: -6, duration: 0.5)
        ])
        arrowBody.run(SKAction.repeatForever(bob))
        arrowHead.run(SKAction.repeatForever(bob))

        let lbl = SKLabelNode(text: label)
        lbl.fontName = "Courier-Bold"; lbl.fontSize = 10
        lbl.fontColor = Colors.lineYellow
        lbl.position = CGPoint(x: 0, y: 62)
        root.addChild(lbl)

        // Glow ring
        let glow = SKShapeNode(circleOfRadius: 28)
        glow.fillColor = Colors.lineYellow.withAlphaComponent(0.15)
        glow.strokeColor = Colors.lineYellow; glow.lineWidth = 2
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.6),
            SKAction.scale(to: 0.9, duration: 0.6)
        ])
        glow.run(SKAction.repeatForever(pulse))
        root.addChild(glow)

        return root
    }

    static func makeDestinationMarker(label: String) -> SKNode {
        let root = SKNode()

        // Checkered flag drawn with squares
        let flagNode = SKNode()
        flagNode.position = CGPoint(x: 0, y: 38)
        let squareSize: CGFloat = 7
        for col in 0..<4 {
            for row in 0..<3 {
                let sq = SKShapeNode(rectOf: CGSize(width: squareSize, height: squareSize))
                sq.fillColor = (col + row) % 2 == 0 ? .black : .white
                sq.strokeColor = .clear
                sq.position = CGPoint(x: CGFloat(col) * squareSize - 10, y: CGFloat(row) * squareSize)
                flagNode.addChild(sq)
            }
        }
        root.addChild(flagNode)

        // Flag pole
        let pole = SKShapeNode(rectOf: CGSize(width: 3, height: 35))
        pole.fillColor = SKColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        pole.strokeColor = .black; pole.lineWidth = 1
        pole.position = CGPoint(x: -12, y: 20)
        root.addChild(pole)

        let lbl = SKLabelNode(text: label)
        lbl.fontName = "Courier-Bold"; lbl.fontSize = 10
        lbl.fontColor = Colors.grassGreen
        lbl.position = CGPoint(x: 0, y: 65)
        root.addChild(lbl)

        let glow = SKShapeNode(circleOfRadius: 28)
        glow.fillColor = Colors.grassGreen.withAlphaComponent(0.15)
        glow.strokeColor = Colors.grassGreen; glow.lineWidth = 2
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.7),
            SKAction.scale(to: 0.9, duration: 0.7)
        ])
        glow.run(SKAction.repeatForever(pulse))
        root.addChild(glow)

        return root
    }

    // MARK: - Hit Effect

    /// "POW!" or "BAM!" label that scales up and fades — call on hit
    static func makeHitEffect(at position: CGPoint) -> SKNode {
        let root = SKNode()
        root.position = position
        root.zPosition = 50

        let texts = ["POW!", "BAM!", "CHOP!", "ZAP!"]
        let lbl = SKLabelNode(text: texts.randomElement()!)
        lbl.fontName = "Courier-Bold"; lbl.fontSize = 22
        lbl.fontColor = Colors.lineYellow
        lbl.strokeColor = .black
        root.addChild(lbl)

        // 8 small squares bursting outward
        for i in 0..<8 {
            let angle = CGFloat(i) * (.pi * 2 / 8)
            let sq = SKShapeNode(rectOf: CGSize(width: 6, height: 6))
            sq.fillColor = [Colors.red, Colors.lineYellow, Colors.orange, .white][i % 4]
            sq.strokeColor = .black; sq.lineWidth = 1
            let dist: CGFloat = CGFloat.random(in: 20...40)
            let dx = cos(angle) * dist; let dy = sin(angle) * dist
            let fly = SKAction.move(by: CGVector(dx: dx, dy: dy), duration: 0.4)
            let fade = SKAction.fadeOut(withDuration: 0.4)
            sq.run(SKAction.sequence([SKAction.group([fly, fade]), SKAction.removeFromParent()]))
            root.addChild(sq)
        }

        // Label scales up and fades
        let grow = SKAction.scale(to: 1.4, duration: 0.15)
        let shrink = SKAction.scale(to: 1.0, duration: 0.1)
        let rise = SKAction.moveBy(x: 0, y: 50, duration: 0.7)
        let fade = SKAction.fadeOut(withDuration: 0.7)
        lbl.run(SKAction.sequence([
            SKAction.group([grow, rise]),
            SKAction.group([shrink, fade]),
            SKAction.removeFromParent()
        ]))
        root.run(SKAction.sequence([SKAction.wait(forDuration: 0.8), SKAction.removeFromParent()]))

        return root
    }

    // MARK: - Power-ups

    static func makePowerup(type: String) -> SKNode {
        let root = SKNode()

        // Pixel art glow box
        let bg = SKShapeNode(rectOf: CGSize(width: 34, height: 34))
        bg.fillColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.15)
        bg.strokeColor = Colors.lineYellow; bg.lineWidth = 2
        root.addChild(bg)

        let inner = SKShapeNode(rectOf: CGSize(width: 28, height: 28))
        inner.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        inner.strokeColor = .clear
        root.addChild(inner)

        let lbl = SKLabelNode(text: type)
        lbl.fontSize = 20; lbl.verticalAlignmentMode = .center
        root.addChild(lbl)

        // Spin
        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 2)
        root.run(SKAction.repeatForever(spin))

        return root
    }

    // MARK: - Score Popup

    static func makeScorePopup(text: String, color: SKColor = Colors.lineYellow) -> SKLabelNode {
        let lbl = SKLabelNode(text: text)
        lbl.fontName = "Courier-Bold"; lbl.fontSize = 20; lbl.fontColor = color
        lbl.zPosition = 100
        let rise = SKAction.moveBy(x: 0, y: 65, duration: 1.0)
        let fade = SKAction.fadeOut(withDuration: 1.0)
        lbl.run(SKAction.sequence([SKAction.group([rise, fade]), SKAction.removeFromParent()]))
        return lbl
    }

    // MARK: - Button

    static func makeButton(text: String, size: CGSize, color: SKColor) -> SKNode {
        let root = SKNode()

        // Dark bottom shadow (3D bevel)
        let shadow = SKShapeNode(rectOf: CGSize(width: size.width + 2, height: size.height + 2))
        shadow.fillColor = .black; shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 1, y: -2)
        root.addChild(shadow)

        // Main button body
        let bg = SKShapeNode(rectOf: size)
        bg.fillColor = color; bg.strokeColor = Colors.black; bg.lineWidth = 3
        root.addChild(bg)

        // Top highlight (lighter strip for 3D bevel)
        let highlight = SKShapeNode(rectOf: CGSize(width: size.width - 6, height: 4))
        highlight.fillColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: 0, y: size.height / 2 - 5)
        root.addChild(highlight)

        let lbl = SKLabelNode(text: text)
        lbl.fontName = "Courier-Bold"; lbl.fontSize = 17; lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center
        root.addChild(lbl)

        return root
    }

    // MARK: - HUD Hearts

    static func makeHeart(filled: Bool) -> SKLabelNode {
        let h = SKLabelNode(text: filled ? "❤️" : "🖤")
        h.fontSize = 22
        return h
    }

    // MARK: - DR Flag (drawn with shapes, no emoji)

    static func makeDRFlag(width: CGFloat = 60, height: CGFloat = 40) -> SKNode {
        let root = SKNode()

        // Background: split into quadrants (blue top-left/bottom-right, red top-right/bottom-left)
        // Top-left: blue
        let tl = SKShapeNode(rectOf: CGSize(width: width / 2, height: height / 2))
        tl.fillColor = Colors.copBlue; tl.strokeColor = .clear
        tl.position = CGPoint(x: -width / 4, y: height / 4)
        root.addChild(tl)

        // Top-right: red
        let tr = SKShapeNode(rectOf: CGSize(width: width / 2, height: height / 2))
        tr.fillColor = Colors.red; tr.strokeColor = .clear
        tr.position = CGPoint(x: width / 4, y: height / 4)
        root.addChild(tr)

        // Bottom-left: red
        let bl = SKShapeNode(rectOf: CGSize(width: width / 2, height: height / 2))
        bl.fillColor = Colors.red; bl.strokeColor = .clear
        bl.position = CGPoint(x: -width / 4, y: -height / 4)
        root.addChild(bl)

        // Bottom-right: blue
        let br = SKShapeNode(rectOf: CGSize(width: width / 2, height: height / 2))
        br.fillColor = Colors.copBlue; br.strokeColor = .clear
        br.position = CGPoint(x: width / 4, y: -height / 4)
        root.addChild(br)

        // White cross
        let crossH = SKShapeNode(rectOf: CGSize(width: width, height: height * 0.12))
        crossH.fillColor = .white; crossH.strokeColor = .clear
        root.addChild(crossH)

        let crossV = SKShapeNode(rectOf: CGSize(width: width * 0.12, height: height))
        crossV.fillColor = .white; crossV.strokeColor = .clear
        root.addChild(crossV)

        // Border
        let border = SKShapeNode(rectOf: CGSize(width: width, height: height))
        border.fillColor = .clear; border.strokeColor = .black; border.lineWidth = 2
        root.addChild(border)

        return root
    }
}
