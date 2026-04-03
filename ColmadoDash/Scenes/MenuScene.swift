// MenuScene.swift — Colmado Dash
// Retro title screen with scrolling background, animated buildings, palm trees

import SpriteKit

class MenuScene: SKScene {

    private var scrollingBG: SKNode!
    private var titleNode: SKNode!
    private var playButton: SKNode!
    private var highScoreLabel: SKLabelNode!
    private var bgSpeed: CGFloat = 40

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.55, green: 0.78, blue: 0.95, alpha: 1) // Sky blue
        buildScrollingBackground()
        buildTitle()
        buildUI()
        animateTitle()
    }

    // MARK: - Background

    private func buildScrollingBackground() {
        scrollingBG = SKNode()
        scrollingBG.zPosition = 0
        addChild(scrollingBG)

        // Two copies side by side for infinite scroll
        for i in 0..<3 {
            let strip = buildCityStrip()
            strip.position = CGPoint(x: CGFloat(i) * frame.width - frame.width, y: 0)
            strip.name = "strip"
            scrollingBG.addChild(strip)
        }
    }

    private func buildCityStrip() -> SKNode {
        let node = SKNode()

        // Road
        let road = SKShapeNode(rectOf: CGSize(width: frame.width, height: frame.height * 0.25))
        road.fillColor = Colors.road; road.strokeColor = .clear
        road.position = CGPoint(x: 0, y: -frame.height * 0.15)
        node.addChild(road)

        // Sidewalk
        let sidewalk = SKShapeNode(rectOf: CGSize(width: frame.width, height: 20))
        sidewalk.fillColor = Colors.sidewalk; sidewalk.strokeColor = .clear
        sidewalk.position = CGPoint(x: 0, y: frame.height * 0.0)
        node.addChild(sidewalk)

        // Buildings (back row)
        var x: CGFloat = -frame.width / 2 + 40
        var colIdx = 0
        while x < frame.width / 2 {
            let w = CGFloat.random(in: 60...100)
            let h = CGFloat.random(in: 80...180)
            let labels = ["COLMADO", "FERRETERÍA", "BANCA", "FARMACIA", "TIENDA", "BAR"]
            let lbl = labels.randomElement()!
            let bldg = SpriteFactory.makeBuilding(width: w, height: h, label: lbl, colorIndex: colIdx)
            bldg.position = CGPoint(x: x, y: frame.height * 0.15)
            bldg.zPosition = 1
            node.addChild(bldg)
            x += w + CGFloat.random(in: 8...20)
            colIdx += 1
        }

        // Palm trees on sidewalk
        for _ in 0..<5 {
            let palm = SpriteFactory.makePalmTree(height: CGFloat.random(in: 55...90))
            palm.position = CGPoint(x: CGFloat.random(in: -frame.width/2...frame.width/2),
                                   y: frame.height * 0.05)
            palm.zPosition = 2
            node.addChild(palm)
        }

        // Ground (dirt patches)
        for _ in 0..<4 {
            let patch = SKShapeNode(ellipseOf: CGSize(width: CGFloat.random(in: 30...70),
                                                      height: CGFloat.random(in: 15...30)))
            patch.fillColor = SKColor(red: 0.45, green: 0.32, blue: 0.18, alpha: 0.5)
            patch.strokeColor = .clear
            patch.position = CGPoint(x: CGFloat.random(in: -frame.width/2...frame.width/2),
                                    y: -frame.height * 0.3 + CGFloat.random(in: -30...30))
            node.addChild(patch)
        }

        return node
    }

    // MARK: - Title

    private func buildTitle() {
        titleNode = SKNode()
        titleNode.zPosition = 10
        titleNode.position = CGPoint(x: 0, y: frame.height * 0.22)
        addChild(titleNode)

        // Shadow
        let shadow = SKLabelNode(text: "DELIVERY LOCO! 🛵")
        shadow.fontName = "AvenirNext-Heavy"
        shadow.fontSize = 46
        shadow.fontColor = SKColor(red: 0.35, green: 0.18, blue: 0.05, alpha: 1)
        shadow.position = CGPoint(x: 3, y: -3)
        titleNode.addChild(shadow)

        // Main title
        let title = SKLabelNode(text: "DELIVERY LOCO! 🛵")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 46
        title.fontColor = Colors.yellow
        titleNode.addChild(title)

        // Subtitle
        let sub = SKLabelNode(text: "🇩🇴 Colmado Dash — Santo Domingo 🇩🇴")
        sub.fontName = "AvenirNext-Bold"
        sub.fontSize = 16
        sub.fontColor = SKColor(red: 1, green: 0.9, blue: 0.7, alpha: 1)
        sub.position = CGPoint(x: 0, y: -45)
        titleNode.addChild(sub)
    }

    private func animateTitle() {
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 8, duration: 0.7),
            SKAction.moveBy(x: 0, y: -8, duration: 0.7)
        ])
        titleNode.run(SKAction.repeatForever(bounce))
    }

    // MARK: - UI Buttons

    private func buildUI() {
        // Colmado building sprite
        let colmado = SpriteFactory.makeBuilding(width: 100, height: 80, label: "COLMADO", colorIndex: 1)
        colmado.position = CGPoint(x: -frame.width * 0.28, y: -frame.height * 0.05)
        colmado.zPosition = 5
        addChild(colmado)

        // Play button
        playButton = SpriteFactory.makeButton(text: "▶  JUGAR", size: CGSize(width: 200, height: 55),
                                               color: SKColor(red: 0.1, green: 0.65, blue: 0.2, alpha: 1))
        playButton.position = CGPoint(x: 0, y: -frame.height * 0.1)
        playButton.zPosition = 10
        playButton.name = "play"
        addChild(playButton)

        let pulsePlay = SKAction.sequence([
            SKAction.scale(to: 1.06, duration: 0.5),
            SKAction.scale(to: 0.97, duration: 0.5)
        ])
        playButton.run(SKAction.repeatForever(pulsePlay))

        // Garage button
        let garageBtn = SpriteFactory.makeButton(text: "🚗 GARAJE", size: CGSize(width: 160, height: 44),
                                                 color: SKColor(red: 0.2, green: 0.3, blue: 0.7, alpha: 1))
        garageBtn.position = CGPoint(x: -100, y: -frame.height * 0.22)
        garageBtn.zPosition = 10; garageBtn.name = "garage"
        addChild(garageBtn)

        // Shop button
        let shopBtn = SpriteFactory.makeButton(text: "🛒 TIENDA", size: CGSize(width: 160, height: 44),
                                               color: SKColor(red: 0.6, green: 0.2, blue: 0.6, alpha: 1))
        shopBtn.position = CGPoint(x: 100, y: -frame.height * 0.22)
        shopBtn.zPosition = 10; shopBtn.name = "shop"
        addChild(shopBtn)

        // High score
        highScoreLabel = SKLabelNode(text: "🏆 RÉCORD: $\(GameState.shared.highScore)")
        highScoreLabel.fontName = "AvenirNext-Bold"
        highScoreLabel.fontSize = 16; highScoreLabel.fontColor = Colors.yellow
        highScoreLabel.position = CGPoint(x: 0, y: frame.height * 0.38)
        highScoreLabel.zPosition = 10
        addChild(highScoreLabel)

        // Cash display
        let cashLbl = SKLabelNode(text: "💵 $\(GameState.shared.money)")
        cashLbl.fontName = "AvenirNext-Bold"
        cashLbl.fontSize = 14; cashLbl.fontColor = .white
        cashLbl.position = CGPoint(x: 0, y: frame.height * 0.33)
        cashLbl.zPosition = 10; cashLbl.name = "cashDisplay"
        addChild(cashLbl)

        // Version
        let ver = SKLabelNode(text: "v1.0 — Hecho con ❤️ en DR")
        ver.fontName = "AvenirNext-Medium"
        ver.fontSize = 11; ver.fontColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        ver.position = CGPoint(x: 0, y: -frame.height * 0.45)
        ver.zPosition = 10
        addChild(ver)
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        // Scroll background
        scrollingBG.children.forEach { strip in
            strip.position.x -= bgSpeed * (1 / 60.0)
            if strip.position.x < -frame.width * 1.5 {
                strip.position.x += frame.width * 3
            }
        }
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let nodes = nodes(at: loc)

        for node in nodes {
            switch node.name {
            case "play":
                SoundManager.shared.playMenuTap()
                goToMissions()
            case "garage":
                SoundManager.shared.playMenuTap()
                goToGarage()
            case "shop":
                SoundManager.shared.playMenuTap()
                goToShop()
            default: break
            }
        }
    }

    private func goToMissions() {
        let scene = MissionSelectScene(size: size)
        scene.scaleMode = .aspectFill
        let trans = SKTransition.push(with: .left, duration: 0.4)
        view?.presentScene(scene, transition: trans)
    }

    private func goToGarage() {
        let scene = GarageScene(size: size)
        scene.scaleMode = .aspectFill
        let trans = SKTransition.push(with: .up, duration: 0.4)
        view?.presentScene(scene, transition: trans)
    }

    private func goToShop() {
        let scene = ShopScene(size: size)
        scene.scaleMode = .aspectFill
        let trans = SKTransition.push(with: .up, duration: 0.4)
        view?.presentScene(scene, transition: trans)
    }
}
