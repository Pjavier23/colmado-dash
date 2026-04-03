// MissionSelectScene.swift — Colmado Dash
// 8-bit Arcade mission selection screen

import SpriteKit

class MissionSelectScene: SKScene {

    private let gs = GameState.shared
    private var selectedMissionId: Int = 0
    private var blinkingArrow: SKNode?

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.10, alpha: 1)
        buildBackground()
        buildUI()
    }

    // MARK: - Background (dark with grid pattern + night skyline)

    private func buildBackground() {
        // Subtle grid pattern
        let gridColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.04)
        let gridSpacing: CGFloat = 30

        var gx = -frame.width / 2
        while gx <= frame.width / 2 {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: gx, y: -frame.height / 2))
            path.addLine(to: CGPoint(x: gx, y: frame.height / 2))
            let l = SKShapeNode(path: path)
            l.strokeColor = gridColor; l.lineWidth = 1; l.zPosition = 0
            addChild(l)
            _ = line
            gx += gridSpacing
        }

        var gy = -frame.height / 2
        while gy <= frame.height / 2 {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -frame.width / 2, y: gy))
            path.addLine(to: CGPoint(x: frame.width / 2, y: gy))
            let l = SKShapeNode(path: path)
            l.strokeColor = gridColor; l.lineWidth = 1; l.zPosition = 0
            addChild(l)
            gy += gridSpacing
        }

        // Night skyline silhouette (buildings at bottom)
        var x: CGFloat = -frame.width / 2
        var ci = 0
        while x < frame.width / 2 {
            let w = CGFloat.random(in: 40...80)
            let h = CGFloat.random(in: 55...130)
            let bldg = SKShapeNode(rectOf: CGSize(width: w - 3, height: h))
            bldg.fillColor = Colors.buildings[ci % Colors.buildings.count].withAlphaComponent(0.35)
            bldg.strokeColor = .black; bldg.lineWidth = 1.5
            bldg.position = CGPoint(x: x + w / 2, y: -frame.height / 2 + h / 2 + 20)
            bldg.zPosition = 1
            addChild(bldg)

            // Lit windows
            for _ in 0..<Int.random(in: 2...5) {
                let win = SKShapeNode(rectOf: CGSize(width: 7, height: 9))
                win.fillColor = CGFloat.random(in: 0...1) > 0.35
                    ? SKColor(red: 1.0, green: 0.97, blue: 0.5, alpha: 0.85)
                    : SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
                win.strokeColor = .black; win.lineWidth = 1
                win.position = CGPoint(
                    x: CGFloat.random(in: -w/2+7...w/2-7),
                    y: CGFloat.random(in: -h/2+10...h/2-18)
                )
                bldg.addChild(win)
            }

            x += w + CGFloat.random(in: 3...10)
            ci += 1
        }

        // Stars
        for _ in 0..<90 {
            let star = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3)))
            star.fillColor = .white; star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: -frame.width/2...frame.width/2),
                y: CGFloat.random(in: -frame.height/4...frame.height/2)
            )
            star.alpha = CGFloat.random(in: 0.3...1.0)
            star.zPosition = 0
            addChild(star)

            // Twinkle some stars
            if Bool.random() {
                let twinkle = SKAction.repeatForever(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.2, duration: CGFloat.random(in: 0.5...1.5)),
                    SKAction.fadeAlpha(to: 1.0, duration: CGFloat.random(in: 0.5...1.5))
                ]))
                star.run(twinkle)
            }
        }
    }

    // MARK: - UI

    private func buildUI() {
        // Title — arcade style
        let titleBg = SKShapeNode(rectOf: CGSize(width: frame.width * 0.75, height: 44))
        titleBg.fillColor = Colors.hudBlack; titleBg.strokeColor = Colors.playerOrange; titleBg.lineWidth = 3
        titleBg.position = CGPoint(x: 0, y: frame.height * 0.39)
        titleBg.zPosition = 5
        addChild(titleBg)

        let title = SKLabelNode(text: "MISIONES")
        title.fontName = "Courier-Bold"; title.fontSize = 26
        title.fontColor = Colors.gold; title.verticalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: frame.height * 0.39)
        title.zPosition = 6
        addChild(title)

        let sub = SKLabelNode(text: "ESCOGE TU ENTREGA, PAPI!")
        sub.fontName = "Courier-Bold"; sub.fontSize = 13
        sub.fontColor = SKColor(red: 0.7, green: 0.9, blue: 1, alpha: 1)
        sub.position = CGPoint(x: 0, y: frame.height * 0.31)
        sub.zPosition = 5
        addChild(sub)

        // Cash display
        let cashBg = SKShapeNode(rectOf: CGSize(width: 200, height: 28))
        cashBg.fillColor = Colors.hudBlack; cashBg.strokeColor = Colors.lineYellow; cashBg.lineWidth = 2
        cashBg.position = CGPoint(x: 0, y: frame.height * 0.245)
        cashBg.zPosition = 5
        addChild(cashBg)

        let cash = SKLabelNode(text: "EFECTIVO: $\(gs.money)")
        cash.fontName = "Courier-Bold"; cash.fontSize = 13
        cash.fontColor = Colors.gold; cash.verticalAlignmentMode = .center
        cash.position = CGPoint(x: 0, y: frame.height * 0.245)
        cash.zPosition = 6
        addChild(cash)

        // Mission cards
        for (i, mission) in gs.missions.enumerated() {
            buildMissionCard(mission: mission, index: i)
        }

        // Back button
        let backBtn = SpriteFactory.makeButton(
            text: "← VOLVER",
            size: CGSize(width: 140, height: 42),
            color: SKColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 0.9)
        )
        backBtn.position = CGPoint(x: 0, y: -frame.height * 0.44)
        backBtn.zPosition = 5; backBtn.name = "back"
        addChild(backBtn)
    }

    private func buildMissionCard(mission: MissionData, index: Int) {
        let cardW: CGFloat = frame.width * 0.86
        let cardH: CGFloat = 76
        let spacing: CGFloat = 84
        let startY: CGFloat = frame.height * 0.17

        let card = SKNode()
        card.position = CGPoint(x: 0, y: startY - CGFloat(index) * spacing)
        card.zPosition = 5
        card.name = "mission_\(mission.id)"
        addChild(card)

        // Black background
        let bg = SKShapeNode(rectOf: CGSize(width: cardW, height: cardH))
        bg.fillColor = SKColor(red: 0.06, green: 0.06, blue: 0.10, alpha: 0.95)
        bg.strokeColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.18); bg.lineWidth = 1.5
        bg.name = "mission_\(mission.id)"
        card.addChild(bg)

        // Colored left border stripe (thick, 6px)
        let stripeColor: SKColor
        switch mission.difficulty {
        case "FÁCIL":  stripeColor = Colors.grassGreen
        case "MEDIO":  stripeColor = Colors.orange
        default:       stripeColor = Colors.red
        }

        let stripe = SKShapeNode(rectOf: CGSize(width: 6, height: cardH))
        stripe.fillColor = stripeColor; stripe.strokeColor = .clear
        stripe.position = CGPoint(x: -cardW / 2 + 3, y: 0)
        stripe.name = "mission_\(mission.id)"
        card.addChild(stripe)

        // Difficulty badge (colored rectangle in corner)
        let badge = SKShapeNode(rectOf: CGSize(width: 62, height: 20))
        badge.fillColor = stripeColor; badge.strokeColor = .black; badge.lineWidth = 1.5
        badge.position = CGPoint(x: -cardW / 2 + 44, y: 22)
        badge.name = "mission_\(mission.id)"
        card.addChild(badge)

        let diffLbl = SKLabelNode(text: mission.difficulty)
        diffLbl.fontName = "Courier-Bold"; diffLbl.fontSize = 10
        diffLbl.fontColor = .white; diffLbl.verticalAlignmentMode = .center
        diffLbl.position = CGPoint(x: -cardW / 2 + 44, y: 22)
        diffLbl.name = "mission_\(mission.id)"
        card.addChild(diffLbl)

        // Mission description text (white)
        let routeLbl = SKLabelNode(text: "PICKUP: \(mission.pickupName)")
        routeLbl.fontName = "Courier-Bold"; routeLbl.fontSize = 12
        routeLbl.fontColor = .white
        routeLbl.horizontalAlignmentMode = .left
        routeLbl.position = CGPoint(x: -cardW / 2 + 16, y: 3)
        routeLbl.name = "mission_\(mission.id)"
        card.addChild(routeLbl)

        let routeLbl2 = SKLabelNode(text: "DROP:   \(mission.dropoffName)")
        routeLbl2.fontName = "Courier-Bold"; routeLbl2.fontSize = 12
        routeLbl2.fontColor = SKColor(red: 0.6, green: 1.0, blue: 0.6, alpha: 1)
        routeLbl2.horizontalAlignmentMode = .left
        routeLbl2.position = CGPoint(x: -cardW / 2 + 16, y: -16)
        routeLbl2.name = "mission_\(mission.id)"
        card.addChild(routeLbl2)

        // Reward in gold/yellow
        let rewardBg = SKShapeNode(rectOf: CGSize(width: 62, height: 30))
        rewardBg.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.0, alpha: 0.8)
        rewardBg.strokeColor = Colors.gold; rewardBg.lineWidth = 2
        rewardBg.position = CGPoint(x: cardW / 2 - 36, y: 0)
        rewardBg.name = "mission_\(mission.id)"
        card.addChild(rewardBg)

        let rewardLbl = SKLabelNode(text: "$\(mission.reward)")
        rewardLbl.fontName = "Courier-Bold"; rewardLbl.fontSize = 18
        rewardLbl.fontColor = Colors.gold; rewardLbl.verticalAlignmentMode = .center
        rewardLbl.horizontalAlignmentMode = .center
        rewardLbl.position = CGPoint(x: cardW / 2 - 36, y: 0)
        rewardLbl.name = "mission_\(mission.id)"
        card.addChild(rewardLbl)

        // Difficulty stars (filled/empty)
        let starCount = mission.difficulty == "FÁCIL" ? 1 : (mission.difficulty == "MEDIO" ? 2 : 3)
        for si in 0..<3 {
            let starLbl = SKLabelNode(text: si < starCount ? "★" : "☆")
            starLbl.fontName = "Courier-Bold"; starLbl.fontSize = 14
            starLbl.fontColor = si < starCount ? Colors.lineYellow : SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
            starLbl.position = CGPoint(x: -cardW / 2 + 120 + CGFloat(si) * 20, y: 22)
            starLbl.name = "mission_\(mission.id)"
            card.addChild(starLbl)
        }

        // Threat tags (drawn as small colored rectangles + text instead of emoji)
        var tagX: CGFloat = -cardW / 2 + 96
        if mission.hasSaboteurs {
            let tag = buildThreatTag(text: "SABO", color: Colors.red)
            tag.position = CGPoint(x: tagX, y: -32)
            tag.name = "mission_\(mission.id)"
            card.addChild(tag)
            tagX += 52
        }
        if mission.hasCops {
            let tag = buildThreatTag(text: "COPS", color: Colors.copBlue)
            tag.position = CGPoint(x: tagX, y: -32)
            tag.name = "mission_\(mission.id)"
            card.addChild(tag)
        }

        // Blinking arrow on first card (selected by default)
        if index == 0 {
            let arrow = buildBlinkingArrow()
            arrow.position = CGPoint(x: cardW / 2 + 14, y: 0)
            card.addChild(arrow)
            blinkingArrow = arrow
        }
    }

    private func buildThreatTag(text: String, color: SKColor) -> SKNode {
        let root = SKNode()
        let bg = SKShapeNode(rectOf: CGSize(width: 44, height: 16))
        bg.fillColor = color; bg.strokeColor = .black; bg.lineWidth = 1.5
        root.addChild(bg)
        let lbl = SKLabelNode(text: text)
        lbl.fontName = "Courier-Bold"; lbl.fontSize = 9
        lbl.fontColor = .white; lbl.verticalAlignmentMode = .center
        root.addChild(lbl)
        return root
    }

    private func buildBlinkingArrow() -> SKNode {
        let root = SKNode()
        let lbl = SKLabelNode(text: "►")
        lbl.fontName = "Courier-Bold"; lbl.fontSize = 20
        lbl.fontColor = Colors.lineYellow; lbl.verticalAlignmentMode = .center
        root.addChild(lbl)

        let blink = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.fadeOut(withDuration: 0.3)
        ]))
        root.run(blink)
        return root
    }

    // MARK: - Touch

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
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }

    private func goBack() {
        let scene = MenuScene(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: SKTransition.push(with: .right, duration: 0.4))
    }
}
