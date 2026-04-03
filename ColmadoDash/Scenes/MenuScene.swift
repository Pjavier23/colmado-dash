// MenuScene.swift — Colmado Dash
// 8-bit Arcade title screen — DR-themed, NES visual style

import SpriteKit

class MenuScene: SKScene {

    private var scrollingBG: SKNode!
    private var titleNode: SKNode!
    private var playButton: SKNode!
    private var highScoreLabel: SKLabelNode!
    private var bgSpeed: CGFloat = 50

    // Parallax layers
    private var bgLayer1: SKNode! // Far buildings (slow)
    private var bgLayer2: SKNode! // Near buildings (faster)
    private var bgLayer3: SKNode! // Road + sidewalk (fastest)

    override func didMove(to view: SKView) {
        backgroundColor = Colors.skyBlue
        buildSky()
        buildScrollingBackground()
        buildTitle()
        buildUI()
    }

    // MARK: - Sky

    private func buildSky() {
        // Gradient sky using layered rectangles
        let skyTop = SKShapeNode(rectOf: CGSize(width: frame.width, height: frame.height * 0.6))
        skyTop.fillColor = Colors.darkBlue; skyTop.strokeColor = .clear
        skyTop.position = CGPoint(x: 0, y: frame.height * 0.2)
        skyTop.zPosition = 0
        addChild(skyTop)

        // Sun in corner
        let sun = SKShapeNode(circleOfRadius: 28)
        sun.fillColor = Colors.lineYellow; sun.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1)
        sun.lineWidth = 4
        sun.position = CGPoint(x: frame.width / 2 - 55, y: frame.height / 2 - 55)
        sun.zPosition = 1
        addChild(sun)

        // Sun rays — 8 rectangles radiating out
        for i in 0..<8 {
            let angle = CGFloat(i) * (.pi / 4)
            let ray = SKShapeNode(rectOf: CGSize(width: 4, height: 20))
            ray.fillColor = Colors.lineYellow; ray.strokeColor = .clear
            ray.position = CGPoint(
                x: sun.position.x + cos(angle) * 38,
                y: sun.position.y + sin(angle) * 38
            )
            ray.zRotation = angle
            ray.zPosition = 1
            addChild(ray)
        }

        // Clouds — simple pixel rectangles
        for _ in 0..<4 {
            let cloud = buildCloud()
            cloud.position = CGPoint(
                x: CGFloat.random(in: -frame.width/2...frame.width/2),
                y: CGFloat.random(in: frame.height * 0.1...frame.height * 0.35)
            )
            cloud.zPosition = 1
            addChild(cloud)
        }
    }

    private func buildCloud() -> SKNode {
        let cloud = SKNode()
        let sizes: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (40, 16, 0, 0), (28, 16, -24, 0), (28, 16, 24, 0),
            (24, 14, -12, 10), (24, 14, 12, 10), (16, 12, 0, 14)
        ]
        for (w, h, x, y) in sizes {
            let sq = SKShapeNode(rectOf: CGSize(width: w, height: h))
            sq.fillColor = .white; sq.strokeColor = .clear
            sq.position = CGPoint(x: x, y: y)
            cloud.addChild(sq)
        }
        return cloud
    }

    // MARK: - Scrolling Background (parallax cityscape)

    private func buildScrollingBackground() {
        scrollingBG = SKNode()
        scrollingBG.zPosition = 2
        addChild(scrollingBG)

        bgLayer1 = SKNode() // Far (slow)
        bgLayer2 = SKNode() // Near (faster)
        bgLayer3 = SKNode() // Road (fastest)

        scrollingBG.addChild(bgLayer1)
        scrollingBG.addChild(bgLayer2)
        scrollingBG.addChild(bgLayer3)

        // Build 3 strip copies for seamless loop
        for i in 0..<3 {
            let xOffset = CGFloat(i) * frame.width - frame.width

            // Layer 1 — far buildings (tall, dark, behind)
            let farStrip = buildFarBuildingStrip()
            farStrip.position = CGPoint(x: xOffset, y: 0)
            farStrip.name = "far"
            bgLayer1.addChild(farStrip)

            // Layer 2 — near buildings
            let nearStrip = buildNearBuildingStrip()
            nearStrip.position = CGPoint(x: xOffset, y: 0)
            nearStrip.name = "near"
            bgLayer2.addChild(nearStrip)

            // Layer 3 — road
            let roadStrip = buildRoadStrip()
            roadStrip.position = CGPoint(x: xOffset, y: 0)
            roadStrip.name = "road"
            bgLayer3.addChild(roadStrip)
        }
    }

    private func buildFarBuildingStrip() -> SKNode {
        let node = SKNode()
        var x: CGFloat = -frame.width / 2
        var ci = 2

        while x < frame.width / 2 {
            let w = CGFloat.random(in: 50...90)
            let h = CGFloat.random(in: 130...200)
            let bldg = SKShapeNode(rectOf: CGSize(width: w - 2, height: h))
            bldg.fillColor = Colors.buildings[ci % Colors.buildings.count].withAlphaComponent(0.5)
            bldg.strokeColor = .black; bldg.lineWidth = 2
            bldg.position = CGPoint(x: x + w / 2, y: -frame.height / 2 + h / 2 + 100)
            bldg.zPosition = 0

            // A few dark windows
            for _ in 0..<4 {
                let win = SKShapeNode(rectOf: CGSize(width: 8, height: 10))
                win.fillColor = SKColor(red: 1.0, green: 0.97, blue: 0.5, alpha: 0.7)
                win.strokeColor = .black; win.lineWidth = 1
                win.position = CGPoint(
                    x: CGFloat.random(in: -w/2+8...w/2-8),
                    y: CGFloat.random(in: -h/2+12...h/2-20)
                )
                bldg.addChild(win)
            }

            node.addChild(bldg)
            x += w + CGFloat.random(in: 5...15)
            ci += 1
        }

        return node
    }

    private func buildNearBuildingStrip() -> SKNode {
        let node = SKNode()
        var x: CGFloat = -frame.width / 2
        var ci = 0

        while x < frame.width / 2 {
            let w = CGFloat.random(in: 70...110)
            let h = CGFloat.random(in: 80...150)
            let label = ["COLMADO", "FARMACIA", "FERRETERÍA", "BAR", "TIENDA"].randomElement()!
            let bldg = SpriteFactory.makeBuilding(width: w, height: h, label: label, colorIndex: ci)
            bldg.position = CGPoint(x: x + w / 2, y: -frame.height / 2 + h / 2 + 90)
            bldg.zPosition = 1
            node.addChild(bldg)

            // Power lines between buildings
            if x + w < frame.width / 2 - 20 {
                let nextX = x + w + CGFloat.random(in: 8...20)
                let wire = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: CGPoint(x: x + w, y: -frame.height / 2 + h + 80))
                path.addLine(to: CGPoint(x: nextX, y: -frame.height / 2 + h + 60))
                let wireLine = SKShapeNode(path: path)
                wireLine.strokeColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
                wireLine.lineWidth = 1.5
                node.addChild(wireLine)
                _ = wire
            }

            // Street light
            if Bool.random() {
                let light = buildStreetLight()
                light.position = CGPoint(x: x + w / 2, y: -frame.height / 2 + 90)
                light.zPosition = 2
                node.addChild(light)
            }

            x += w + CGFloat.random(in: 8...20)
            ci += 1
        }

        return node
    }

    private func buildStreetLight() -> SKNode {
        let root = SKNode()

        // Pole — tall thin
        let pole = SKShapeNode(rectOf: CGSize(width: 4, height: 70))
        pole.fillColor = SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        pole.strokeColor = .black; pole.lineWidth = 1
        pole.position = CGPoint(x: 0, y: 35)
        root.addChild(pole)

        // Light — circular at top
        let light = SKShapeNode(circleOfRadius: 8)
        light.fillColor = Colors.lineYellow; light.strokeColor = .black; light.lineWidth = 1.5
        light.position = CGPoint(x: 0, y: 72)
        root.addChild(light)

        // Glow
        let glow = SKShapeNode(circleOfRadius: 12)
        glow.fillColor = Colors.lineYellow.withAlphaComponent(0.25); glow.strokeColor = .clear
        glow.position = CGPoint(x: 0, y: 72)
        root.addChild(glow)

        return root
    }

    private func buildRoadStrip() -> SKNode {
        let node = SKNode()
        let roadY = -frame.height / 2 + 70
        let roadH: CGFloat = 80

        // Road surface
        let road = SKShapeNode(rectOf: CGSize(width: frame.width, height: roadH))
        road.fillColor = Colors.roadGray; road.strokeColor = .clear
        road.position = CGPoint(x: 0, y: roadY)
        node.addChild(road)

        // Road edge lines (white)
        for edgeY in [roadY + roadH / 2 - 4, roadY - roadH / 2 + 4] {
            let edge = SKShapeNode(rectOf: CGSize(width: frame.width, height: 3))
            edge.fillColor = .white; edge.strokeColor = .clear
            edge.position = CGPoint(x: 0, y: edgeY)
            node.addChild(edge)
        }

        // Dashed center line (yellow)
        var dx: CGFloat = -frame.width / 2
        while dx < frame.width / 2 {
            let dash = SKShapeNode(rectOf: CGSize(width: 28, height: 4))
            dash.fillColor = Colors.lineYellow; dash.strokeColor = .clear
            dash.position = CGPoint(x: dx + 14, y: roadY)
            node.addChild(dash)
            dx += 60
        }

        // Sidewalk
        let sidewalk = SKShapeNode(rectOf: CGSize(width: frame.width, height: 22))
        sidewalk.fillColor = Colors.sidewalkTan; sidewalk.strokeColor = .clear
        sidewalk.position = CGPoint(x: 0, y: roadY + roadH / 2 + 11)
        node.addChild(sidewalk)

        // Brick pattern on sidewalk (alternating tiles)
        var bx: CGFloat = -frame.width / 2
        var rowOffset = false
        var by: CGFloat = 0
        for _ in 0..<2 {
            bx = rowOffset ? -frame.width / 2 + 12 : -frame.width / 2
            while bx < frame.width / 2 {
                let tile = SKShapeNode(rectOf: CGSize(width: 22, height: 9))
                tile.fillColor = SKColor(red: 0.70, green: 0.64, blue: 0.50, alpha: 1)
                tile.strokeColor = SKColor(red: 0.58, green: 0.52, blue: 0.40, alpha: 1)
                tile.lineWidth = 1
                tile.position = CGPoint(x: bx + 11, y: roadY + roadH / 2 + 11 + by)
                node.addChild(tile)
                bx += 24
            }
            rowOffset = !rowOffset
            by += 10
        }

        // Manholes on road
        for _ in 0..<3 {
            let manhole = SKShapeNode(circleOfRadius: 9)
            manhole.fillColor = SKColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1)
            manhole.strokeColor = SKColor(red: 0.35, green: 0.35, blue: 0.35, alpha: 1)
            manhole.lineWidth = 2
            manhole.position = CGPoint(
                x: CGFloat.random(in: -frame.width/2 + 20...frame.width/2 - 20),
                y: roadY + CGFloat.random(in: -15...15)
            )
            node.addChild(manhole)
        }

        // Road cracks
        for _ in 0..<4 {
            let crack = SKShapeNode()
            let path = CGMutablePath()
            let cx = CGFloat.random(in: -frame.width/2+20...frame.width/2-20)
            let cy = roadY + CGFloat.random(in: -20...20)
            path.move(to: CGPoint(x: cx, y: cy))
            path.addLine(to: CGPoint(x: cx + CGFloat.random(in: 8...18), y: cy + CGFloat.random(in: -10...10)))
            let crackLine = SKShapeNode(path: path)
            crackLine.strokeColor = SKColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 0.7)
            crackLine.lineWidth = 1.5
            node.addChild(crackLine)
        }

        return node
    }

    // MARK: - Title

    private func buildTitle() {
        titleNode = SKNode()
        titleNode.zPosition = 10
        titleNode.position = CGPoint(x: 0, y: frame.height * 0.20)
        addChild(titleNode)

        // Thick 8-bit shadow (multiple offset copies)
        for (ox, oy): (CGFloat, CGFloat) in [(4, -4), (3, -3), (2, -2)] {
            let shadow = SKLabelNode(text: "DELIVERY LOCO!")
            shadow.fontName = "AvenirNext-Heavy"; shadow.fontSize = 44
            shadow.fontColor = SKColor(red: 0.3, green: 0.0, blue: 0.0, alpha: 1)
            shadow.position = CGPoint(x: ox, y: oy)
            titleNode.addChild(shadow)
        }

        // Main title — gold
        let title = SKLabelNode(text: "DELIVERY LOCO!")
        title.fontName = "AvenirNext-Heavy"; title.fontSize = 44
        title.fontColor = Colors.gold
        titleNode.addChild(title)

        // Subtitle
        let sub = SKLabelNode(text: "COLMADO COURIER")
        sub.fontName = "Courier-Bold"; sub.fontSize = 18
        sub.fontColor = Colors.white
        sub.position = CGPoint(x: 0, y: -48)
        titleNode.addChild(sub)

        // DR Flag (drawn with shapes)
        let flag = SpriteFactory.makeDRFlag(width: 54, height: 36)
        flag.position = CGPoint(x: 0, y: -78)
        titleNode.addChild(flag)

        // Bouncing animation
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 8, duration: 0.7),
            SKAction.moveBy(x: 0, y: -8, duration: 0.7)
        ])
        titleNode.run(SKAction.repeatForever(bounce))
    }

    // MARK: - UI Buttons

    private func buildUI() {
        // "PRESS START" blinking text
        let pressStart = SKLabelNode(text: "▶ PRESS START ◀")
        pressStart.fontName = "Courier-Bold"; pressStart.fontSize = 20
        pressStart.fontColor = Colors.white
        pressStart.position = CGPoint(x: 0, y: -frame.height * 0.07)
        pressStart.zPosition = 10
        pressStart.name = "play"
        addChild(pressStart)

        let blink = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.5)
        ]))
        pressStart.run(blink)

        // Play button (larger, green, arcade)
        playButton = SpriteFactory.makeButton(
            text: "▶  JUGAR",
            size: CGSize(width: 200, height: 55),
            color: SKColor(red: 0.08, green: 0.55, blue: 0.15, alpha: 1)
        )
        playButton.position = CGPoint(x: 0, y: -frame.height * 0.16)
        playButton.zPosition = 10; playButton.name = "play"
        addChild(playButton)

        let pulsePlay = SKAction.sequence([
            SKAction.scale(to: 1.06, duration: 0.5),
            SKAction.scale(to: 0.97, duration: 0.5)
        ])
        playButton.run(SKAction.repeatForever(pulsePlay))

        // Garage button
        let garageBtn = SpriteFactory.makeButton(
            text: "GARAJE",
            size: CGSize(width: 148, height: 44),
            color: Colors.blue
        )
        garageBtn.position = CGPoint(x: -90, y: -frame.height * 0.27)
        garageBtn.zPosition = 10; garageBtn.name = "garage"
        addChild(garageBtn)

        // Shop button
        let shopBtn = SpriteFactory.makeButton(
            text: "TIENDA",
            size: CGSize(width: 148, height: 44),
            color: Colors.purple
        )
        shopBtn.position = CGPoint(x: 90, y: -frame.height * 0.27)
        shopBtn.zPosition = 10; shopBtn.name = "shop"
        addChild(shopBtn)

        // Hi-Score — arcade format
        let hiScore = GameState.shared.highScore
        highScoreLabel = SKLabelNode(text: String(format: "HI-SCORE  %06d", hiScore))
        highScoreLabel.fontName = "Courier-Bold"
        highScoreLabel.fontSize = 16; highScoreLabel.fontColor = Colors.gold
        highScoreLabel.position = CGPoint(x: 0, y: frame.height * 0.38)
        highScoreLabel.zPosition = 10
        addChild(highScoreLabel)

        // Cash display
        let cashLbl = SKLabelNode(text: "EFECTIVO: $\(GameState.shared.money)")
        cashLbl.fontName = "Courier-Bold"
        cashLbl.fontSize = 13; cashLbl.fontColor = Colors.white
        cashLbl.position = CGPoint(x: 0, y: frame.height * 0.33)
        cashLbl.zPosition = 10
        addChild(cashLbl)

        // Version
        let ver = SKLabelNode(text: "v1.0  HECHO EN DR")
        ver.fontName = "Courier-Bold"
        ver.fontSize = 11
        ver.fontColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.45)
        ver.position = CGPoint(x: 0, y: -frame.height * 0.46)
        ver.zPosition = 10
        addChild(ver)
    }

    // MARK: - Update (parallax scroll)

    override func update(_ currentTime: TimeInterval) {
        let dt: CGFloat = 1 / 60.0

        // Three layers at different speeds (parallax)
        let speed1: CGFloat = bgSpeed * 0.3  // far — slow
        let speed2: CGFloat = bgSpeed * 0.7  // near — medium
        let speed3: CGFloat = bgSpeed * 1.0  // road — fast

        for layer in [(bgLayer1!, speed1), (bgLayer2!, speed2), (bgLayer3!, speed3)] {
            let (node, speed) = layer
            node.children.forEach { strip in
                strip.position.x -= speed * dt
                if strip.position.x < -frame.width * 1.5 {
                    strip.position.x += frame.width * 3
                }
            }
        }
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let tapped = nodes(at: loc)

        for node in tapped {
            switch node.name {
            case "play":
                SoundManager.shared.playMenuTap()
                goToMissions()
                return
            case "garage":
                SoundManager.shared.playMenuTap()
                goToGarage()
                return
            case "shop":
                SoundManager.shared.playMenuTap()
                goToShop()
                return
            default: break
            }
        }
    }

    private func goToMissions() {
        let scene = MissionSelectScene(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: SKTransition.push(with: .left, duration: 0.4))
    }

    private func goToGarage() {
        let scene = GarageScene(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: SKTransition.push(with: .up, duration: 0.4))
    }

    private func goToShop() {
        let scene = ShopScene(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: SKTransition.push(with: .up, duration: 0.4))
    }
}
