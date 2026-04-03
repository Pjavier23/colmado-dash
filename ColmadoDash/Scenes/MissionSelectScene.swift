// MissionSelectScene.swift — Colmado Dash
// Mission selection screen

import SpriteKit

class MissionSelectScene: SKScene {

    private let gs = GameState.shared
    private var selectedMissionId: Int = 0

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.08, green: 0.10, blue: 0.18, alpha: 1)
        buildBackground()
        buildUI()
    }

    private func buildBackground() {
        // Stars
        for _ in 0..<80 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2))
            star.fillColor = .white
            star.strokeColor = .clear
            star.position = CGPoint(x: CGFloat.random(in: -frame.width/2...frame.width/2),
                                   y: CGFloat.random(in: -frame.height/2...frame.height/2))
            star.alpha = CGFloat.random(in: 0.3...1.0)
            addChild(star)
        }

        // Night skyline
        var x: CGFloat = -frame.width / 2
        var ci = 0
        while x < frame.width / 2 {
            let w = CGFloat.random(in: 45...85)
            let h = CGFloat.random(in: 60...140)
            let bldg = SKShapeNode(rectOf: CGSize(width: w - 4, height: h))
            bldg.fillColor = Colors.buildings[ci % Colors.buildings.count].withAlphaComponent(0.6)
            bldg.strokeColor = .clear
            bldg.position = CGPoint(x: x + w/2, y: -frame.height/2 + h/2 + 30)
            bldg.zPosition = 1
            addChild(bldg)
            // Lit windows
            for _ in 0..<3 {
                let win = SKShapeNode(rectOf: CGSize(width: 6, height: 8))
                win.fillColor = CGFloat.random(in: 0...1) > 0.4 ?
                    SKColor(red: 1, green: 1, blue: 0.7, alpha: 0.9) : .clear
                win.position = CGPoint(x: CGFloat.random(in: -w/2+6...w/2-6),
                                      y: CGFloat.random(in: -h/2+8...h/2-8))
                bldg.addChild(win)
            }
            x += w + 4
            ci += 1
        }
    }

    private func buildUI() {
        // Title
        let title = SKLabelNode(text: "📋 MISIONES")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 34; title.fontColor = Colors.yellow
        title.position = CGPoint(x: 0, y: frame.height * 0.38)
        title.zPosition = 5
        addChild(title)

        let sub = SKLabelNode(text: "¡Escoge tu entrega, papi!")
        sub.fontName = "AvenirNext-Bold"
        sub.fontSize = 14; sub.fontColor = SKColor(red: 0.7, green: 0.9, blue: 1, alpha: 1)
        sub.position = CGPoint(x: 0, y: frame.height * 0.30)
        sub.zPosition = 5
        addChild(sub)

        // Cash display
        let cash = SKLabelNode(text: "💵 Efectivo: $\(gs.money)")
        cash.fontName = "AvenirNext-Bold"
        cash.fontSize = 14; cash.fontColor = .white
        cash.position = CGPoint(x: 0, y: frame.height * 0.24)
        cash.zPosition = 5
        addChild(cash)

        // Mission cards
        for (i, mission) in gs.missions.enumerated() {
            buildMissionCard(mission: mission, index: i)
        }

        // Back button
        let backBtn = SpriteFactory.makeButton(text: "← VOLVER", size: CGSize(width: 140, height: 40),
                                               color: SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8))
        backBtn.position = CGPoint(x: 0, y: -frame.height * 0.44)
        backBtn.zPosition = 5; backBtn.name = "back"
        addChild(backBtn)
    }

    private func buildMissionCard(mission: MissionData, index: Int) {
        let cardW: CGFloat = frame.width * 0.85
        let cardH: CGFloat = 72
        let spacing: CGFloat = 82
        let startY: CGFloat = frame.height * 0.17

        let card = SKNode()
        card.position = CGPoint(x: 0, y: startY - CGFloat(index) * spacing)
        card.zPosition = 5
        card.name = "mission_\(mission.id)"
        addChild(card)

        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: cardW, height: cardH), cornerRadius: 10)
        let diffColor: SKColor
        switch mission.difficulty {
        case "FÁCIL":   diffColor = SKColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 0.85)
        case "MEDIO":   diffColor = SKColor(red: 0.5, green: 0.4, blue: 0.0, alpha: 0.85)
        default:        diffColor = SKColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 0.85)
        }
        bg.fillColor = diffColor
        bg.strokeColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        bg.lineWidth = 1.5
        bg.name = "mission_\(mission.id)"
        card.addChild(bg)

        // Difficulty badge
        let badge = SKShapeNode(rectOf: CGSize(width: 65, height: 22), cornerRadius: 6)
        badge.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        badge.position = CGPoint(x: -cardW/2 + 40, y: 18)
        badge.name = "mission_\(mission.id)"
        card.addChild(badge)

        let diffLbl = SKLabelNode(text: mission.difficulty)
        diffLbl.fontName = "AvenirNext-Bold"
        diffLbl.fontSize = 11; diffLbl.fontColor = .white
        diffLbl.verticalAlignmentMode = .center
        diffLbl.position = CGPoint(x: -cardW/2 + 40, y: 18)
        diffLbl.name = "mission_\(mission.id)"
        card.addChild(diffLbl)

        // Route description
        let routeLbl = SKLabelNode(text: "📦 \(mission.pickupName)")
        routeLbl.fontName = "AvenirNext-Bold"
        routeLbl.fontSize = 13; routeLbl.fontColor = .white
        routeLbl.horizontalAlignmentMode = .left
        routeLbl.position = CGPoint(x: -cardW/2 + 14, y: 2)
        routeLbl.name = "mission_\(mission.id)"
        card.addChild(routeLbl)

        let routeLbl2 = SKLabelNode(text: "🏁 \(mission.dropoffName)")
        routeLbl2.fontName = "AvenirNext-Bold"
        routeLbl2.fontSize = 13; routeLbl2.fontColor = SKColor(red: 0.8, green: 1, blue: 0.8, alpha: 1)
        routeLbl2.horizontalAlignmentMode = .left
        routeLbl2.position = CGPoint(x: -cardW/2 + 14, y: -16)
        routeLbl2.name = "mission_\(mission.id)"
        card.addChild(routeLbl2)

        // Reward
        let rewardLbl = SKLabelNode(text: "$\(mission.reward)")
        rewardLbl.fontName = "AvenirNext-Heavy"
        rewardLbl.fontSize = 22; rewardLbl.fontColor = Colors.yellow
        rewardLbl.horizontalAlignmentMode = .right
        rewardLbl.verticalAlignmentMode = .center
        rewardLbl.position = CGPoint(x: cardW/2 - 20, y: 0)
        rewardLbl.name = "mission_\(mission.id)"
        card.addChild(rewardLbl)

        // Tags
        var tagX: CGFloat = -cardW/2 + 80
        if mission.hasSaboteurs {
            let tag = SKLabelNode(text: "😈")
            tag.fontSize = 14; tag.position = CGPoint(x: tagX, y: 18)
            tag.name = "mission_\(mission.id)"
            card.addChild(tag)
            tagX += 24
        }
        if mission.hasCops {
            let tag = SKLabelNode(text: "🚔")
            tag.fontSize = 14; tag.position = CGPoint(x: tagX, y: 18)
            tag.name = "mission_\(mission.id)"
            card.addChild(tag)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let tNodes = nodes(at: loc)

        for n in tNodes {
            if let name = n.name {
                if name.hasPrefix("mission_"), let idStr = name.split(separator: "_").last,
                   let id = Int(idStr) {
                    SoundManager.shared.playMenuTap()
                    startMission(id: id)
                    return
                }
                if name == "back" {
                    SoundManager.shared.playMenuTap()
                    goBack()
                    return
                }
            }
        }
    }

    private func startMission(id: Int) {
        guard let mission = gs.missions.first(where: { $0.id == id }) else { return }
        gs.reset()
        let scene = GameScene(size: size)
        scene.scaleMode = .aspectFill
        scene.selectedMission = mission
        let trans = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(scene, transition: trans)
    }

    private func goBack() {
        let scene = MenuScene(size: size)
        scene.scaleMode = .aspectFill
        let trans = SKTransition.push(with: .right, duration: 0.4)
        view?.presentScene(scene, transition: trans)
    }
}
