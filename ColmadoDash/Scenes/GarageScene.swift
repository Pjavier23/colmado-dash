// GarageScene.swift — Colmado Dash
// Vehicle selection and upgrade shop

import SpriteKit

class GarageScene: SKScene {

    private let gs = GameState.shared
    private var selectedVehicle: VehicleType = GameState.shared.vehicle
    private var cards: [VehicleType: SKNode] = [:]

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.08, green: 0.10, blue: 0.14, alpha: 1)
        buildBackground()
        buildUI()
    }

    private func buildBackground() {
        // Floor grid (garage look)
        for x in stride(from: -frame.width/2, to: frame.width/2, by: 60.0) {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: -frame.height/2))
            path.addLine(to: CGPoint(x: x, y: frame.height/2))
            let n = SKShapeNode(path: path)
            n.strokeColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 0.5)
            n.lineWidth = 1
            addChild(n)
        }
        for y in stride(from: -frame.height/2, to: frame.height/2, by: 60.0) {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -frame.width/2, y: y))
            path.addLine(to: CGPoint(x: frame.width/2, y: y))
            let n = SKShapeNode(path: path)
            n.strokeColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 0.5)
            n.lineWidth = 1
            addChild(n)
        }
    }

    private func buildUI() {
        // Title
        let title = SKLabelNode(text: "🚗 GARAJE")
        title.fontName = "AvenirNext-Heavy"; title.fontSize = 36; title.fontColor = Colors.yellow
        title.position = CGPoint(x: 0, y: frame.height * 0.42); title.zPosition = 5
        addChild(title)

        let cash = SKLabelNode(text: "💵 $\(gs.money)")
        cash.fontName = "AvenirNext-Bold"; cash.fontSize = 18; cash.fontColor = .white
        cash.position = CGPoint(x: 0, y: frame.height * 0.34); cash.zPosition = 5
        addChild(cash)

        // Vehicle cards
        let vehicles: [VehicleType] = [.bicycle, .moped, .car, .concho]
        let cardW: CGFloat = (frame.width - 60) / 2
        let cardH: CGFloat = 180
        let positions: [CGPoint] = [
            CGPoint(x: -cardW/2 - 10, y:  cardH/2 + 20),
            CGPoint(x:  cardW/2 + 10, y:  cardH/2 + 20),
            CGPoint(x: -cardW/2 - 10, y: -cardH/2 - 20),
            CGPoint(x:  cardW/2 + 10, y: -cardH/2 - 20),
        ]

        for (i, v) in vehicles.enumerated() {
            let card = buildVehicleCard(vehicle: v, size: CGSize(width: cardW, height: cardH))
            card.position = positions[i]
            card.zPosition = 5
            card.name = "vehicle_\(v.rawValue)"
            addChild(card)
            cards[v] = card
        }

        // Back button
        let backBtn = SpriteFactory.makeButton(text: "← VOLVER", size: CGSize(width: 140, height: 40),
                                               color: SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.9))
        backBtn.position = CGPoint(x: 0, y: -frame.height * 0.44)
        backBtn.zPosition = 5; backBtn.name = "back"
        addChild(backBtn)

        updateCardSelection()
    }

    private func buildVehicleCard(vehicle: VehicleType, size: CGSize) -> SKNode {
        let card = SKNode()

        let bg = SKShapeNode(rectOf: size, cornerRadius: 12)
        let owned = gs.ownedVehicles.contains(vehicle)
        bg.fillColor = owned ? SKColor(red: 0.1, green: 0.25, blue: 0.45, alpha: 0.9)
                             : SKColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 0.9)
        bg.strokeColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        bg.lineWidth = 1.5
        bg.name = "vehicle_\(vehicle.rawValue)"
        card.addChild(bg)

        // Vehicle sprite
        let vehicleSprite = SpriteFactory.makePlayer(type: vehicle)
        vehicleSprite.position = CGPoint(x: 0, y: size.height * 0.15)
        vehicleSprite.setScale(1.3)
        vehicleSprite.name = "vehicle_\(vehicle.rawValue)"
        card.addChild(vehicleSprite)

        // Name
        let nameLbl = SKLabelNode(text: vehicle.displayName)
        nameLbl.fontName = "AvenirNext-Heavy"; nameLbl.fontSize = 15; nameLbl.fontColor = Colors.yellow
        nameLbl.position = CGPoint(x: 0, y: -size.height * 0.1)
        nameLbl.name = "vehicle_\(vehicle.rawValue)"
        card.addChild(nameLbl)

        // Price or OWNED
        let priceLbl: SKLabelNode
        if owned {
            priceLbl = SKLabelNode(text: vehicle == gs.vehicle ? "✅ ACTIVO" : "✔ TUYO")
            priceLbl.fontColor = SKColor(red: 0.3, green: 1, blue: 0.4, alpha: 1)
        } else {
            priceLbl = SKLabelNode(text: "$\(vehicle.price)")
            priceLbl.fontColor = Colors.yellow
        }
        priceLbl.fontName = "AvenirNext-Bold"; priceLbl.fontSize = 16
        priceLbl.position = CGPoint(x: 0, y: -size.height * 0.24)
        priceLbl.name = "vehicle_\(vehicle.rawValue)"
        card.addChild(priceLbl)

        // Stat bars
        let statY: CGFloat = -size.height * 0.35
        addStatBar(parent: card, label: "VEL", value: vehicle.speed / 280, y: statY,
                   color: SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1), width: size.width * 0.7)
        addStatBar(parent: card, label: "DEF", value: CGFloat(vehicle.defense) / 4, y: statY - 18,
                   color: SKColor(red: 0.2, green: 0.4, blue: 1, alpha: 1), width: size.width * 0.7)

        return card
    }

    private func addStatBar(parent: SKNode, label: String, value: CGFloat, y: CGFloat, color: SKColor, width: CGFloat) {
        let lbl = SKLabelNode(text: label)
        lbl.fontName = "AvenirNext-Bold"; lbl.fontSize = 9; lbl.fontColor = .gray
        lbl.horizontalAlignmentMode = .left
        lbl.position = CGPoint(x: -width/2, y: y)
        parent.addChild(lbl)

        let trackW = width - 30
        let track = SKShapeNode(rectOf: CGSize(width: trackW, height: 7), cornerRadius: 3)
        track.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1); track.strokeColor = .clear
        track.position = CGPoint(x: trackW/2 - width/2 + 26, y: y + 3)
        parent.addChild(track)

        let fill = SKShapeNode(rectOf: CGSize(width: max(4, trackW * value), height: 7), cornerRadius: 3)
        fill.fillColor = color; fill.strokeColor = .clear
        fill.position = CGPoint(x: (trackW * value / 2) - trackW/2 + trackW/2 - width/2 + 26, y: y + 3)
        parent.addChild(fill)
    }

    private func updateCardSelection() {
        for (vehicle, card) in cards {
            let bg = card.children.first as? SKShapeNode
            if vehicle == selectedVehicle {
                bg?.strokeColor = Colors.yellow
                bg?.lineWidth = 3
            } else {
                bg?.strokeColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.2)
                bg?.lineWidth = 1.5
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let tNodes = nodes(at: loc)

        for n in tNodes {
            guard let name = n.name else { continue }
            if name == "back" {
                SoundManager.shared.playMenuTap()
                goBack(); return
            }
            if name.hasPrefix("vehicle_") {
                let rawValue = String(name.dropFirst("vehicle_".count))
                if let v = VehicleType(rawValue: rawValue) {
                    tappedVehicle(v)
                    return
                }
            }
        }
    }

    private func tappedVehicle(_ vehicle: VehicleType) {
        selectedVehicle = vehicle
        updateCardSelection()

        if gs.ownedVehicles.contains(vehicle) {
            // Equip it
            gs.vehicle = vehicle
            gs.save()
            SoundManager.shared.playMenuTap()
            showMessage("¡\(vehicle.displayName) equipada! 🚀")
        } else {
            // Try to buy
            if gs.money >= vehicle.price {
                let ok = gs.buyVehicle(vehicle)
                if ok {
                    SoundManager.shared.playPurchase()
                    showMessage("¡Compraste \(vehicle.displayName)! 🎉")
                    refreshCards()
                }
            } else {
                let need = vehicle.price - gs.money
                showMessage("Faltan $\(need) 💸")
            }
        }
    }

    private func refreshCards() {
        removeAllChildren()
        buildBackground()
        buildUI()
    }

    private func showMessage(_ text: String) {
        let popup = SpriteFactory.makeScorePopup(text: text, color: Colors.yellow)
        popup.position = CGPoint(x: 0, y: 0)
        popup.zPosition = 20
        addChild(popup)
    }

    private func goBack() {
        let scene = MenuScene(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: SKTransition.push(with: .down, duration: 0.4))
    }
}
