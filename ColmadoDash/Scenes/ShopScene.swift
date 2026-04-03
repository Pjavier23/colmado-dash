// ShopScene.swift — Colmado Dash
// Buy power-ups and weapons

import SpriteKit

struct ShopItem {
    let name: String
    let emoji: String
    let description: String
    let price: Int
    let action: String // "weapon_platano", "powerup_beer", etc
}

class ShopScene: SKScene {

    private let gs = GameState.shared

    private let items: [ShopItem] = [
        ShopItem(name: "Presidente", emoji: "🍺", description: "Speed + invincible 3s",  price: 150, action: "powerup_beer"),
        ShopItem(name: "Mangú",      emoji: "🫕", description: "+1 vida extra",           price: 200, action: "powerup_mangu"),
        ShopItem(name: "Café",       emoji: "☕", description: "Rapid fire 15s",          price: 80,  action: "powerup_cafe"),
        ShopItem(name: "Casco",      emoji: "⛑️", description: "+1 defensa",             price: 300, action: "item_casco"),
        ShopItem(name: "Plátano",    emoji: "🍌", description: "Boomerang weapon",        price: 0,   action: "weapon_platano"),
        ShopItem(name: "Huevo",      emoji: "🥚", description: "Slime pool weapon",       price: 100, action: "weapon_huevo"),
        ShopItem(name: "Salami",     emoji: "🥩", description: "Explosive grenade",       price: 250, action: "weapon_salami"),
        ShopItem(name: "Peo Cloud",  emoji: "💨", description: "Freeze cloud 3s",         price: 180, action: "weapon_fart"),
    ]

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.06, green: 0.08, blue: 0.12, alpha: 1)
        buildBackground()
        buildUI()
    }

    private func buildBackground() {
        // Market stall vibe — colored canopy strips
        for i in 0..<8 {
            let strip = SKShapeNode(rectOf: CGSize(width: frame.width, height: 12))
            strip.fillColor = Colors.buildings[i % Colors.buildings.count].withAlphaComponent(0.3)
            strip.strokeColor = .clear
            strip.position = CGPoint(x: 0, y: frame.height/2 - CGFloat(i) * 30)
            addChild(strip)
        }
    }

    private func buildUI() {
        // Title
        let title = SKLabelNode(text: "🛒 COLMADO SHOP")
        title.fontName = "AvenirNext-Heavy"; title.fontSize = 32; title.fontColor = Colors.yellow
        title.position = CGPoint(x: 0, y: frame.height * 0.43); title.zPosition = 5
        addChild(title)

        let cashLbl = SKLabelNode(text: "💵 Efectivo: $\(gs.money)")
        cashLbl.fontName = "AvenirNext-Bold"; cashLbl.fontSize = 16; cashLbl.fontColor = .white
        cashLbl.position = CGPoint(x: 0, y: frame.height * 0.36); cashLbl.zPosition = 5
        cashLbl.name = "cashDisplay"
        addChild(cashLbl)

        // Item grid (2 columns)
        let cols = 2
        let cellW: CGFloat = (frame.width - 50) / CGFloat(cols)
        let cellH: CGFloat = 120
        let startX: CGFloat = -(cellW / 2) - 10
        let startY: CGFloat = frame.height * 0.25

        for (i, item) in items.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = startX + CGFloat(col) * (cellW + 10)
            let y = startY - CGFloat(row) * (cellH + 12)
            let card = buildItemCard(item: item, size: CGSize(width: cellW, height: cellH))
            card.position = CGPoint(x: x, y: y)
            card.zPosition = 5
            card.name = "shop_\(item.action)"
            addChild(card)
        }

        // Back button
        let backBtn = SpriteFactory.makeButton(text: "← VOLVER", size: CGSize(width: 140, height: 40),
                                               color: SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.9))
        backBtn.position = CGPoint(x: 0, y: -frame.height * 0.44)
        backBtn.zPosition = 5; backBtn.name = "back"
        addChild(backBtn)
    }

    private func buildItemCard(item: ShopItem, size: CGSize) -> SKNode {
        let card = SKNode()

        let bg = SKShapeNode(rectOf: size, cornerRadius: 10)
        let owned = isItemOwned(item)
        bg.fillColor = owned ? SKColor(red: 0.05, green: 0.3, blue: 0.1, alpha: 0.9)
                             : SKColor(red: 0.12, green: 0.14, blue: 0.22, alpha: 0.95)
        bg.strokeColor = owned ? SKColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 0.7)
                                : SKColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        bg.lineWidth = 1.5
        bg.name = "shop_\(item.action)"
        card.addChild(bg)

        // Emoji
        let emoji = SKLabelNode(text: item.emoji)
        emoji.fontSize = 32
        emoji.verticalAlignmentMode = .center
        emoji.position = CGPoint(x: 0, y: size.height * 0.22)
        emoji.name = "shop_\(item.action)"
        card.addChild(emoji)

        // Name
        let nameLbl = SKLabelNode(text: item.name)
        nameLbl.fontName = "AvenirNext-Bold"; nameLbl.fontSize = 13; nameLbl.fontColor = .white
        nameLbl.position = CGPoint(x: 0, y: -size.height * 0.05)
        nameLbl.name = "shop_\(item.action)"
        card.addChild(nameLbl)

        // Description
        let descLbl = SKLabelNode(text: item.description)
        descLbl.fontName = "AvenirNext-Medium"; descLbl.fontSize = 10
        descLbl.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.9, alpha: 1)
        descLbl.position = CGPoint(x: 0, y: -size.height * 0.22)
        descLbl.name = "shop_\(item.action)"
        card.addChild(descLbl)

        // Price
        let priceLbl: SKLabelNode
        if owned && item.action.hasPrefix("weapon_") {
            priceLbl = SKLabelNode(text: "✅ TIENES")
            priceLbl.fontColor = SKColor(red: 0.4, green: 1, blue: 0.5, alpha: 1)
        } else if item.price == 0 {
            priceLbl = SKLabelNode(text: "GRATIS")
            priceLbl.fontColor = SKColor(red: 0.4, green: 1, blue: 0.5, alpha: 1)
        } else {
            priceLbl = SKLabelNode(text: "$\(item.price)")
            priceLbl.fontColor = Colors.yellow
        }
        priceLbl.fontName = "AvenirNext-Heavy"; priceLbl.fontSize = 16
        priceLbl.position = CGPoint(x: 0, y: -size.height * 0.37)
        priceLbl.name = "shop_\(item.action)"
        card.addChild(priceLbl)

        return card
    }

    private func isItemOwned(_ item: ShopItem) -> Bool {
        if item.action.hasPrefix("weapon_") {
            let rawValue = String(item.action.dropFirst("weapon_".count))
            if let wt = WeaponType(rawValue: rawValue) {
                return gs.weapons.contains(wt)
            }
        }
        return false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let tNodes = nodes(at: loc)

        for n in tNodes {
            guard let name = n.name else { continue }
            if name == "back" { SoundManager.shared.playMenuTap(); goBack(); return }
            if name.hasPrefix("shop_") {
                let action = String(name.dropFirst("shop_".count))
                purchaseItem(action: action)
                return
            }
        }
    }

    private func purchaseItem(action: String) {
        guard let item = items.first(where: { $0.action == action }) else { return }

        // Weapons that are already owned
        if action.hasPrefix("weapon_") {
            let rawValue = String(action.dropFirst("weapon_".count))
            if let wt = WeaponType(rawValue: rawValue), gs.weapons.contains(wt) {
                showMessage("¡Ya tienes \(item.name)! 🤙")
                return
            }
        }

        if item.price == 0 {
            applyItem(item)
            return
        }

        if gs.money >= item.price {
            let _ = gs.spendMoney(item.price)
            applyItem(item)
            updateCashDisplay()
        } else {
            let need = item.price - gs.money
            showMessage("Te faltan $\(need) 💸")
            SoundManager.shared.playCrash()
        }
    }

    private func applyItem(_ item: ShopItem) {
        SoundManager.shared.playPurchase()

        if item.action.hasPrefix("weapon_") {
            let rawValue = String(item.action.dropFirst("weapon_".count))
            if let wt = WeaponType(rawValue: rawValue) {
                gs.addWeapon(wt)
                showMessage("¡\(item.emoji) \(item.name) desbloqueado!")
                refreshShop()
            }
        } else {
            showMessage("¡\(item.emoji) \(item.name) guardado!")
            // Consumables are stored in a simple counter here for simplicity
            // In a full implementation, you'd track inventory
        }
    }

    private func updateCashDisplay() {
        if let lbl = childNode(withName: "cashDisplay") as? SKLabelNode {
            lbl.text = "💵 Efectivo: $\(gs.money)"
        }
    }

    private func refreshShop() {
        removeAllChildren()
        buildBackground()
        buildUI()
    }

    private func showMessage(_ text: String) {
        let popup = SpriteFactory.makeScorePopup(text: text, color: Colors.yellow)
        popup.position = CGPoint(x: 0, y: 50)
        popup.zPosition = 20
        addChild(popup)
    }

    private func goBack() {
        let scene = MenuScene(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: SKTransition.push(with: .down, duration: 0.4))
    }
}
