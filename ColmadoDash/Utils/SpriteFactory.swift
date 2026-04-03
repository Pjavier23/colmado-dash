// SpriteFactory.swift — Colmado Dash
// All game sprites drawn programmatically. No external image assets needed.

import SpriteKit

struct Colors {
    static let road      = SKColor(red: 0.35, green: 0.35, blue: 0.35, alpha: 1)
    static let sidewalk  = SKColor(red: 0.62, green: 0.60, blue: 0.50, alpha: 1)
    static let player    = SKColor(red: 1.00, green: 0.45, blue: 0.09, alpha: 1)
    static let enemy     = SKColor(red: 0.90, green: 0.10, blue: 0.10, alpha: 1)
    static let cop       = SKColor(red: 0.10, green: 0.20, blue: 0.80, alpha: 1)
    static let hudBG     = SKColor(red: 0, green: 0, blue: 0, alpha: 0.80)
    static let yellow    = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1)
    static let buildings: [SKColor] = [
        SKColor(red: 0.85, green: 0.20, blue: 0.20, alpha: 1),
        SKColor(red: 0.10, green: 0.40, blue: 0.80, alpha: 1),
        SKColor(red: 0.55, green: 0.10, blue: 0.65, alpha: 1),
        SKColor(red: 0.95, green: 0.55, blue: 0.05, alpha: 1),
        SKColor(red: 0.10, green: 0.65, blue: 0.35, alpha: 1),
    ]
}

enum SpriteFactory {

    // MARK: - Player Vehicles

    static func makePlayer(type: VehicleType) -> SKNode {
        let root = SKNode()
        switch type {
        case .bicycle: return makeBicycle()
        case .moped:   return makeMoped()
        case .car:     return makeCar()
        case .concho:  return makeConcho()
        }
    }

    static func makeBicycle() -> SKNode {
        let root = SKNode()
        // Frame
        let frame = SKShapeNode(rectOf: CGSize(width: 22, height: 10), cornerRadius: 2)
        frame.fillColor = Colors.player; frame.strokeColor = .black; frame.lineWidth = 1
        root.addChild(frame)
        // Wheels
        for x: CGFloat in [-10, 10] {
            let w = SKShapeNode(circleOfRadius: 7)
            w.fillColor = .darkGray; w.strokeColor = .black; w.lineWidth = 1.5
            w.position = CGPoint(x: x, y: 0)
            root.addChild(w)
        }
        // Rider head
        let head = SKShapeNode(circleOfRadius: 5)
        head.fillColor = SKColor(red: 0.95, green: 0.75, blue: 0.55, alpha: 1)
        head.strokeColor = .black; head.lineWidth = 1
        head.position = CGPoint(x: 0, y: 12)
        root.addChild(head)
        return root
    }

    static func makeMoped() -> SKNode {
        let root = SKNode()
        let body = SKShapeNode(rectOf: CGSize(width: 30, height: 14), cornerRadius: 4)
        body.fillColor = Colors.player; body.strokeColor = .black; body.lineWidth = 1
        root.addChild(body)
        // Exhaust
        let exhaust = SKShapeNode(rectOf: CGSize(width: 6, height: 4), cornerRadius: 1)
        exhaust.fillColor = .gray; exhaust.position = CGPoint(x: -18, y: -3)
        root.addChild(exhaust)
        for x: CGFloat in [-12, 12] {
            let w = SKShapeNode(circleOfRadius: 7)
            w.fillColor = .darkGray; w.strokeColor = .black; w.lineWidth = 1.5
            w.position = CGPoint(x: x, y: 0)
            root.addChild(w)
        }
        let head = SKShapeNode(circleOfRadius: 5)
        head.fillColor = SKColor(red: 0.95, green: 0.75, blue: 0.55, alpha: 1)
        head.strokeColor = .black; head.lineWidth = 1
        head.position = CGPoint(x: 3, y: 13)
        root.addChild(head)
        // Helmet
        let helmet = SKShapeNode(rectOf: CGSize(width: 10, height: 6), cornerRadius: 5)
        helmet.fillColor = Colors.yellow; helmet.position = CGPoint(x: 3, y: 16)
        root.addChild(helmet)
        return root
    }

    static func makeCar() -> SKNode {
        let root = SKNode()
        // Body
        let body = SKShapeNode(rectOf: CGSize(width: 44, height: 22), cornerRadius: 4)
        body.fillColor = Colors.player; body.strokeColor = .black; body.lineWidth = 1.5
        root.addChild(body)
        // Roof
        let roof = SKShapeNode(rectOf: CGSize(width: 28, height: 12), cornerRadius: 5)
        roof.fillColor = SKColor(red: 0.8, green: 0.35, blue: 0.05, alpha: 1)
        roof.position = CGPoint(x: 0, y: 8)
        root.addChild(roof)
        // Windows
        let win = SKShapeNode(rectOf: CGSize(width: 20, height: 8), cornerRadius: 2)
        win.fillColor = SKColor(red: 0.6, green: 0.9, blue: 1.0, alpha: 0.8)
        win.position = CGPoint(x: 0, y: 9)
        root.addChild(win)
        for (x, y): (CGFloat, CGFloat) in [(-18, -6), (18, -6), (-18, 6), (18, 6)] {
            let w = SKShapeNode(circleOfRadius: 8)
            w.fillColor = .darkGray; w.strokeColor = .black; w.lineWidth = 2
            w.position = CGPoint(x: x, y: y)
            root.addChild(w)
        }
        return root
    }

    static func makeConcho() -> SKNode {
        let root = SKNode()
        let body = SKShapeNode(rectOf: CGSize(width: 50, height: 24), cornerRadius: 5)
        body.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1) // Concho = yellow taxi
        body.strokeColor = .black; body.lineWidth = 1.5
        root.addChild(body)
        // Stripe
        let stripe = SKShapeNode(rectOf: CGSize(width: 50, height: 5))
        stripe.fillColor = SKColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1)
        stripe.position = CGPoint(x: 0, y: 0)
        root.addChild(stripe)
        let roof = SKShapeNode(rectOf: CGSize(width: 30, height: 14), cornerRadius: 5)
        roof.fillColor = SKColor(red: 0.9, green: 0.75, blue: 0.0, alpha: 1)
        roof.position = CGPoint(x: 0, y: 9)
        root.addChild(roof)
        let win = SKShapeNode(rectOf: CGSize(width: 22, height: 10), cornerRadius: 2)
        win.fillColor = SKColor(red: 0.6, green: 0.9, blue: 1.0, alpha: 0.8)
        win.position = CGPoint(x: 0, y: 10)
        root.addChild(win)
        for (x, y): (CGFloat, CGFloat) in [(-20, -8), (20, -8), (-20, 8), (20, 8)] {
            let w = SKShapeNode(circleOfRadius: 8)
            w.fillColor = .darkGray; w.strokeColor = .black; w.lineWidth = 2
            w.position = CGPoint(x: x, y: y)
            root.addChild(w)
        }
        return root
    }

    // MARK: - Enemies

    static func makeEnemy() -> SKNode {
        let root = SKNode()
        // Body
        let body = SKShapeNode(rectOf: CGSize(width: 14, height: 18), cornerRadius: 2)
        body.fillColor = Colors.enemy; body.strokeColor = .black; body.lineWidth = 1
        root.addChild(body)
        // Head
        let head = SKShapeNode(circleOfRadius: 6)
        head.fillColor = SKColor(red: 0.95, green: 0.75, blue: 0.55, alpha: 1)
        head.strokeColor = .black; head.lineWidth = 1
        head.position = CGPoint(x: 0, y: 15)
        root.addChild(head)
        // Arms
        for x: CGFloat in [-10, 10] {
            let arm = SKShapeNode(rectOf: CGSize(width: 5, height: 14), cornerRadius: 2)
            arm.fillColor = Colors.enemy; arm.position = CGPoint(x: x, y: 2)
            root.addChild(arm)
        }
        return root
    }

    static func makeCopCar() -> SKNode {
        let root = SKNode()
        let body = SKShapeNode(rectOf: CGSize(width: 44, height: 22), cornerRadius: 4)
        body.fillColor = Colors.cop; body.strokeColor = .black; body.lineWidth = 1.5
        root.addChild(body)
        // Light bar
        let bar = SKShapeNode(rectOf: CGSize(width: 20, height: 5), cornerRadius: 2)
        bar.fillColor = .darkGray; bar.position = CGPoint(x: 0, y: 14)
        root.addChild(bar)
        let redLight = SKShapeNode(circleOfRadius: 3)
        redLight.fillColor = .red; redLight.position = CGPoint(x: -5, y: 14)
        root.addChild(redLight)
        let blueLight = SKShapeNode(circleOfRadius: 3)
        blueLight.fillColor = SKColor(red: 0.3, green: 0.3, blue: 1, alpha: 1)
        blueLight.position = CGPoint(x: 5, y: 14)
        root.addChild(blueLight)
        for (x, y): (CGFloat, CGFloat) in [(-18, -6), (18, -6), (-18, 6), (18, 6)] {
            let w = SKShapeNode(circleOfRadius: 8)
            w.fillColor = .darkGray; w.strokeColor = .black; w.lineWidth = 2
            w.position = CGPoint(x: x, y: y)
            root.addChild(w)
        }
        let winText = SKLabelNode(text: "POLICIA")
        winText.fontSize = 6; winText.fontColor = .white
        winText.fontName = "AvenirNext-Bold"
        winText.position = CGPoint(x: 0, y: -2)
        root.addChild(winText)
        return root
    }

    // MARK: - Buildings

    static func makeBuilding(width: CGFloat, height: CGFloat, label: String, colorIndex: Int) -> SKNode {
        let root = SKNode()
        let color = Colors.buildings[colorIndex % Colors.buildings.count]
        let bldg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 3)
        bldg.fillColor = color; bldg.strokeColor = .black; bldg.lineWidth = 1.5
        bldg.position = CGPoint(x: 0, y: height / 2)
        root.addChild(bldg)
        // Windows
        let cols = max(1, Int(width / 25))
        let rows = max(1, Int(height / 30))
        for col in 0..<cols {
            for row in 0..<rows {
                let win = SKShapeNode(rectOf: CGSize(width: 10, height: 12), cornerRadius: 1)
                win.fillColor = Bool.random() ? SKColor(red: 1, green: 1, blue: 0.7, alpha: 0.9) : SKColor(red: 0.4, green: 0.4, blue: 0.6, alpha: 0.7)
                let startX = -width / 2 + 15 + CGFloat(col) * (width / CGFloat(cols))
                let startY = 12 + CGFloat(row) * 28
                win.position = CGPoint(x: startX, y: startY)
                bldg.addChild(win)
            }
        }
        // Label sign
        let lbl = SKLabelNode(text: label)
        lbl.fontSize = min(11, width / CGFloat(label.count) * 1.4)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontColor = .white
        lbl.position = CGPoint(x: 0, y: 4)
        bldg.addChild(lbl)
        return root
    }

    // MARK: - Palm Tree

    static func makePalmTree(height: CGFloat = 70) -> SKNode {
        let root = SKNode()
        // Trunk
        let trunk = SKShapeNode(rectOf: CGSize(width: 8, height: height), cornerRadius: 3)
        trunk.fillColor = SKColor(red: 0.55, green: 0.38, blue: 0.18, alpha: 1)
        trunk.strokeColor = SKColor(red: 0.35, green: 0.22, blue: 0.08, alpha: 1)
        trunk.position = CGPoint(x: 0, y: height / 2)
        root.addChild(trunk)
        // Leaves
        let leafColor = SKColor(red: 0.10, green: 0.60, blue: 0.15, alpha: 1)
        for angle in stride(from: 0.0, to: 360.0, by: 45.0) {
            let leaf = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: 30, y: 10))
            path.addLine(to: CGPoint(x: 25, y: -5))
            path.closeSubpath()
            leaf.path = path
            leaf.fillColor = leafColor; leaf.strokeColor = .clear
            leaf.zRotation = CGFloat(angle) * .pi / 180
            leaf.position = CGPoint(x: 0, y: height)
            root.addChild(leaf)
        }
        return root
    }

    // MARK: - Package / Pickup Marker

    static func makePackage() -> SKNode {
        let root = SKNode()
        let box = SKShapeNode(rectOf: CGSize(width: 16, height: 16), cornerRadius: 2)
        box.fillColor = SKColor(red: 0.65, green: 0.42, blue: 0.15, alpha: 1)
        box.strokeColor = .black; box.lineWidth = 1.5
        root.addChild(box)
        // Cross tape
        let h = SKShapeNode(rectOf: CGSize(width: 16, height: 3))
        h.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.0, alpha: 1); h.strokeColor = .clear
        root.addChild(h)
        let v = SKShapeNode(rectOf: CGSize(width: 3, height: 16))
        v.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.0, alpha: 1); v.strokeColor = .clear
        root.addChild(v)
        return root
    }

    static func makePickupMarker(label: String) -> SKNode {
        let root = SKNode()
        // Arrow pointing down
        let arrow = SKLabelNode(text: "⬇️")
        arrow.fontSize = 28
        arrow.position = CGPoint(x: 0, y: 30)
        root.addChild(arrow)
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 6, duration: 0.5),
            SKAction.moveBy(x: 0, y: -6, duration: 0.5)
        ])
        arrow.run(SKAction.repeatForever(bob))
        let lbl = SKLabelNode(text: label)
        lbl.fontSize = 10; lbl.fontName = "AvenirNext-Bold"; lbl.fontColor = Colors.yellow
        lbl.position = CGPoint(x: 0, y: 60)
        root.addChild(lbl)
        // Circle glow
        let glow = SKShapeNode(circleOfRadius: 28)
        glow.fillColor = Colors.yellow.withAlphaComponent(0.15)
        glow.strokeColor = Colors.yellow; glow.lineWidth = 2
        glow.position = .zero
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
        let arrow = SKLabelNode(text: "🏁")
        arrow.fontSize = 28; arrow.position = CGPoint(x: 0, y: 30)
        root.addChild(arrow)
        let lbl = SKLabelNode(text: label)
        lbl.fontSize = 10; lbl.fontName = "AvenirNext-Bold"; lbl.fontColor = .green
        lbl.position = CGPoint(x: 0, y: 60)
        root.addChild(lbl)
        let glow = SKShapeNode(circleOfRadius: 28)
        glow.fillColor = SKColor.green.withAlphaComponent(0.15)
        glow.strokeColor = .green; glow.lineWidth = 2
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.7),
            SKAction.scale(to: 0.9, duration: 0.7)
        ])
        glow.run(SKAction.repeatForever(pulse))
        root.addChild(glow)
        return root
    }

    // MARK: - Power-ups

    static func makePowerup(type: String) -> SKNode {
        let root = SKNode()
        let bg = SKShapeNode(circleOfRadius: 16)
        bg.fillColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        bg.strokeColor = .white; bg.lineWidth = 2
        root.addChild(bg)
        let lbl = SKLabelNode(text: type)
        lbl.fontSize = 20; lbl.verticalAlignmentMode = .center
        root.addChild(lbl)
        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 2)
        root.run(SKAction.repeatForever(spin))
        return root
    }

    // MARK: - Star / Score Popup

    static func makeScorePopup(text: String, color: SKColor = .yellow) -> SKLabelNode {
        let lbl = SKLabelNode(text: text)
        lbl.fontSize = 22; lbl.fontName = "AvenirNext-Bold"; lbl.fontColor = color
        lbl.zPosition = 100
        let rise = SKAction.moveBy(x: 0, y: 60, duration: 1.0)
        let fade = SKAction.fadeOut(withDuration: 1.0)
        lbl.run(SKAction.sequence([SKAction.group([rise, fade]), SKAction.removeFromParent()]))
        return lbl
    }

    // MARK: - Button helper

    static func makeButton(text: String, size: CGSize, color: SKColor) -> SKNode {
        let root = SKNode()
        let bg = SKShapeNode(rectOf: size, cornerRadius: 10)
        bg.fillColor = color; bg.strokeColor = .white; bg.lineWidth = 2
        root.addChild(bg)
        let lbl = SKLabelNode(text: text)
        lbl.fontName = "AvenirNext-Bold"; lbl.fontSize = 18; lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center
        root.addChild(lbl)
        return root
    }

    // MARK: - HUD hearts

    static func makeHeart(filled: Bool) -> SKLabelNode {
        let h = SKLabelNode(text: filled ? "❤️" : "🖤")
        h.fontSize = 22
        return h
    }
}
