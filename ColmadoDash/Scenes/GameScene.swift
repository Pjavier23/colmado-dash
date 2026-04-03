// GameScene.swift — Colmado Dash
// Main game: top-down Santo Domingo courier action

import SpriteKit

struct PhysicsCategory {
    static let player:   UInt32 = 0x1 << 0
    static let enemy:    UInt32 = 0x1 << 1
    static let weapon:   UInt32 = 0x1 << 2
    static let building: UInt32 = 0x1 << 3
    static let pickup:   UInt32 = 0x1 << 4
    static let powerup:  UInt32 = 0x1 << 5
}

class GameScene: SKScene, SKPhysicsContactDelegate, HUDDelegate {

    // MARK: - Properties
    var selectedMission: MissionData!
    private let gs = GameState.shared

    // Nodes
    private var worldNode: SKNode!
    private var player: Player!
    private var hud: HUD!
    private var cameraNode: SKCameraNode!

    // World bounds
    private let worldWidth:  CGFloat = 2400
    private let worldHeight: CGFloat = 2400

    // Game state
    private var lives: Int = 3
    private var timeElapsed: TimeInterval = 0
    private var lastUpdate: TimeInterval = 0
    private var joystickDirection: CGVector = .zero
    private var isGameOver = false
    private var missionComplete = false

    // Enemies
    private var enemies: [Enemy] = []
    private var enemySpawnTimer: TimeInterval = 0
    private var enemySpawnInterval: TimeInterval = 3.0

    // Powerups
    private var powerupSpawnTimer: TimeInterval = 0
    private var powerupSpawnInterval: TimeInterval = 8.0

    // Delivery
    private var deliveryManager: DeliveryManager!

    // Weapon
    private var currentWeaponType: WeaponType { gs.currentWeapon }
    private var weaponCooldown: TimeInterval = 0
    private let weaponCooldownBase: TimeInterval = 0.5

    // MARK: - Setup

    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        buildWorld()
        buildPlayer()
        buildCamera()
        buildHUD()
        setupDelivery()

        // Difficulty
        let hard = selectedMission?.hasCops ?? false
        enemySpawnInterval = hard ? 2.0 : 4.0
    }

    private func buildWorld() {
        worldNode = SKNode()
        worldNode.name = "world"
        addChild(worldNode)

        buildRoad()
        buildBuildings()
        buildPalmTrees()
        buildWorldBounds()
    }

    private func buildRoad() {
        // Background ground — sidewalk tan
        let ground = SKShapeNode(rectOf: CGSize(width: worldWidth, height: worldHeight))
        ground.fillColor = Colors.sidewalkTan; ground.strokeColor = .clear
        ground.position = .zero
        worldNode.addChild(ground)

        // Horizontal roads with full markings
        for y in stride(from: -worldHeight/2, to: worldHeight/2, by: 300.0) {
            let road = SKShapeNode(rectOf: CGSize(width: worldWidth, height: 80))
            road.fillColor = Colors.roadGray; road.strokeColor = .clear
            road.position = CGPoint(x: 0, y: y)
            road.zPosition = 1
            worldNode.addChild(road)

            // Solid edge lines (white) at top & bottom of road
            for edgeOffset: CGFloat in [-38, 38] {
                let edge = SKShapeNode(rectOf: CGSize(width: worldWidth, height: 3))
                edge.fillColor = .white; edge.strokeColor = .clear
                edge.position = CGPoint(x: 0, y: y + edgeOffset)
                edge.zPosition = 2
                worldNode.addChild(edge)
            }

            // Dashed center line (yellow)
            for x in stride(from: -worldWidth/2, to: worldWidth/2, by: 60.0) {
                let dash = SKShapeNode(rectOf: CGSize(width: 30, height: 4))
                dash.fillColor = Colors.lineYellow; dash.strokeColor = .clear
                dash.position = CGPoint(x: x + 15, y: y)
                dash.zPosition = 2
                worldNode.addChild(dash)
            }

            // Manholes on road
            for _ in 0..<6 {
                let manhole = SKShapeNode(circleOfRadius: 9)
                manhole.fillColor = SKColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1)
                manhole.strokeColor = SKColor(red: 0.38, green: 0.38, blue: 0.38, alpha: 1)
                manhole.lineWidth = 2
                manhole.position = CGPoint(
                    x: CGFloat.random(in: -worldWidth/2+20...worldWidth/2-20),
                    y: y + CGFloat.random(in: -30...30)
                )
                manhole.zPosition = 2
                worldNode.addChild(manhole)
            }

            // Road cracks
            for _ in 0..<8 {
                let crackPath = CGMutablePath()
                let cx = CGFloat.random(in: -worldWidth/2+20...worldWidth/2-20)
                let cy = y + CGFloat.random(in: -25...25)
                crackPath.move(to: CGPoint(x: cx, y: cy))
                crackPath.addLine(to: CGPoint(x: cx + CGFloat.random(in: 8...20),
                                              y: cy + CGFloat.random(in: -12...12)))
                let crack = SKShapeNode(path: crackPath)
                crack.strokeColor = SKColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 0.65)
                crack.lineWidth = 1.5; crack.zPosition = 2
                worldNode.addChild(crack)
            }
        }

        // Vertical roads
        for x in stride(from: -worldWidth/2, to: worldWidth/2, by: 300.0) {
            let road = SKShapeNode(rectOf: CGSize(width: 80, height: worldHeight))
            road.fillColor = Colors.roadGray; road.strokeColor = .clear
            road.position = CGPoint(x: x, y: 0)
            road.zPosition = 1
            worldNode.addChild(road)

            // Edge lines
            for edgeOffset: CGFloat in [-38, 38] {
                let edge = SKShapeNode(rectOf: CGSize(width: 3, height: worldHeight))
                edge.fillColor = .white; edge.strokeColor = .clear
                edge.position = CGPoint(x: x + edgeOffset, y: 0)
                edge.zPosition = 2
                worldNode.addChild(edge)
            }

            // Dashed center line (yellow, vertical)
            for y in stride(from: -worldHeight/2, to: worldHeight/2, by: 60.0) {
                let dash = SKShapeNode(rectOf: CGSize(width: 4, height: 30))
                dash.fillColor = Colors.lineYellow; dash.strokeColor = .clear
                dash.position = CGPoint(x: x, y: y + 15)
                dash.zPosition = 2
                worldNode.addChild(dash)
            }
        }

        // Sidewalk brick tiles along road edges
        buildSidewalkTiles()
    }

    private func buildSidewalkTiles() {
        // Add brick-patterned sidewalk strips along horizontal roads
        for y in stride(from: -worldHeight/2, to: worldHeight/2, by: 300.0) {
            for sideY in [y + 48, y - 48] {
                var bx: CGFloat = -worldWidth / 2
                var rowToggle = false
                for _ in 0..<2 {
                    bx = rowToggle ? -worldWidth/2 + 12 : -worldWidth/2
                    while bx < worldWidth / 2 {
                        let tile = SKShapeNode(rectOf: CGSize(width: 22, height: 10))
                        tile.fillColor = SKColor(red: 0.70, green: 0.64, blue: 0.50, alpha: 0.9)
                        tile.strokeColor = SKColor(red: 0.55, green: 0.49, blue: 0.37, alpha: 0.9)
                        tile.lineWidth = 1
                        tile.position = CGPoint(x: bx + 11, y: sideY)
                        tile.zPosition = 2
                        worldNode.addChild(tile)
                        bx += 24
                    }
                    rowToggle = !rowToggle
                    _ = sideY
                }
            }
        }
    }

    private func buildBuildings() {
        // Place buildings in the blocks between roads — taller, NES arcade style
        let buildingLabels = ["COLMADO", "FERRETERÍA", "BANCA", "FARMACIA", "TIENDA",
                              "BAR", "BARBERÍA", "PANADERÍA", "POLLERÍA", "EL CHINO"]
        var colorIdx = 0

        for blockY in stride(from: -worldHeight/2 + 180, to: worldHeight/2 - 150, by: 300.0) {
            for blockX in stride(from: -worldWidth/2 + 180, to: worldWidth/2 - 150, by: 300.0) {
                // Taller buildings to fill more screen
                let bW = CGFloat.random(in: 90...150)
                let bH = CGFloat.random(in: 100...200)
                let label = buildingLabels.randomElement()!
                let bldg = SpriteFactory.makeBuilding(width: bW, height: bH, label: label, colorIndex: colorIdx)
                bldg.position = CGPoint(x: blockX + CGFloat.random(in: -30...30),
                                        y: blockY + CGFloat.random(in: -30...30))
                bldg.zPosition = 3

                // Building physics
                let phys = SKPhysicsBody(rectangleOf: CGSize(width: bW, height: bH),
                                         center: CGPoint(x: 0, y: bH / 2))
                phys.isDynamic = false
                phys.categoryBitMask = PhysicsCategory.building
                phys.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
                phys.contactTestBitMask = 0
                bldg.physicsBody = phys

                worldNode.addChild(bldg)
                colorIdx += 1
            }
        }

        // Power lines between some buildings
        buildPowerLines()

        // Street lights along roads
        buildStreetLights()
    }

    private func buildPowerLines() {
        // Horizontal power lines along road edges
        for y in stride(from: -worldHeight/2 + 150, to: worldHeight/2 - 150, by: 300.0) {
            var prevPoleX: CGFloat = -worldWidth / 2 + 60
            while prevPoleX < worldWidth / 2 - 60 {
                let nextPoleX = prevPoleX + CGFloat.random(in: 100...180)

                // Pole
                let pole = SKShapeNode(rectOf: CGSize(width: 4, height: 80))
                pole.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
                pole.strokeColor = .black; pole.lineWidth = 1
                pole.position = CGPoint(x: prevPoleX, y: y + 40)
                pole.zPosition = 3
                worldNode.addChild(pole)

                // Wire
                let wirePath = CGMutablePath()
                wirePath.move(to: CGPoint(x: prevPoleX, y: y + 80))
                wirePath.addLine(to: CGPoint(x: nextPoleX, y: y + 72))
                let wire = SKShapeNode(path: wirePath)
                wire.strokeColor = SKColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 0.8)
                wire.lineWidth = 1.5; wire.zPosition = 3
                worldNode.addChild(wire)

                prevPoleX = nextPoleX
            }
        }
    }

    private func buildStreetLights() {
        for y in stride(from: -worldHeight/2 + 100, to: worldHeight/2 - 100, by: 150.0) {
            for x in stride(from: -worldWidth/2 + 100, to: worldWidth/2 - 100, by: 200.0) {
                // Only place on road edges (approximate)
                let isOnRoad = Int((y + worldHeight/2) / 300) != Int((y + worldHeight/2 + 40) / 300)
                guard isOnRoad else { continue }

                // Pole
                let pole = SKShapeNode(rectOf: CGSize(width: 4, height: 60))
                pole.fillColor = SKColor(red: 0.45, green: 0.45, blue: 0.48, alpha: 1)
                pole.strokeColor = .black; pole.lineWidth = 1
                pole.position = CGPoint(x: x, y: y + 30)
                pole.zPosition = 3
                worldNode.addChild(pole)

                // Light head
                let light = SKShapeNode(circleOfRadius: 7)
                light.fillColor = Colors.lineYellow
                light.strokeColor = .black; light.lineWidth = 1.5
                light.position = CGPoint(x: x, y: y + 62)
                light.zPosition = 3
                worldNode.addChild(light)

                // Soft glow
                let glow = SKShapeNode(circleOfRadius: 14)
                glow.fillColor = Colors.lineYellow.withAlphaComponent(0.15)
                glow.strokeColor = .clear
                glow.position = CGPoint(x: x, y: y + 62)
                glow.zPosition = 2
                worldNode.addChild(glow)
            }
        }
    }

    private func buildPalmTrees() {
        for _ in 0..<60 {
            let palm = SpriteFactory.makePalmTree(height: CGFloat.random(in: 50...90))
            palm.position = CGPoint(x: CGFloat.random(in: -worldWidth/2...worldWidth/2),
                                   y: CGFloat.random(in: -worldHeight/2...worldHeight/2))
            palm.zPosition = 3
            worldNode.addChild(palm)
        }
    }

    private func buildWorldBounds() {
        let walls = [
            CGRect(x: -worldWidth/2 - 20, y: -worldHeight/2, width: 20, height: worldHeight),
            CGRect(x:  worldWidth/2,      y: -worldHeight/2, width: 20, height: worldHeight),
            CGRect(x: -worldWidth/2,      y: -worldHeight/2 - 20, width: worldWidth, height: 20),
            CGRect(x: -worldWidth/2,      y:  worldHeight/2,       width: worldWidth, height: 20),
        ]
        for rect in walls {
            let wall = SKShapeNode(rect: rect)
            wall.fillColor = .clear; wall.strokeColor = .clear
            let body = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: rect.size))
            body.isDynamic = false
            body.categoryBitMask = PhysicsCategory.building
            body.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
            wall.physicsBody = body
            wall.position = CGPoint(x: rect.minX, y: rect.minY)
            worldNode.addChild(wall)
        }
    }

    private func buildPlayer() {
        player = Player(vehicleType: gs.vehicle)
        player.position = CGPoint(x: -100, y: -100)
        player.zPosition = 10
        worldNode.addChild(player)
    }

    private func buildCamera() {
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
    }

    private func buildHUD() {
        hud = HUD(size: size)
        hud.delegate = self
        hud.zPosition = 100
        cameraNode.addChild(hud)
    }

    private func setupDelivery() {
        deliveryManager = DeliveryManager(mission: selectedMission, scene: self)
        deliveryManager.onPickup = { [weak self] in
            self?.player.pickUpPackage()
            self?.showPopup(text: "📦 ¡Paquete recogido!", color: Colors.yellow)
        }
        deliveryManager.onComplete = { [weak self] reward in
            self?.completeMission(reward: reward)
        }
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver, !missionComplete else { return }
        let dt = lastUpdate == 0 ? 0 : currentTime - lastUpdate
        lastUpdate = currentTime
        timeElapsed += dt

        // Move player
        player.move(direction: joystickDirection)

        // Clamp player to world
        let pw = player.position
        player.position = CGPoint(
            x: pw.x.clamped(to: -worldWidth/2 + 30 ... worldWidth/2 - 30),
            y: pw.y.clamped(to: -worldHeight/2 + 30 ... worldHeight/2 - 30)
        )

        // Camera follows player
        cameraNode.position = player.position

        // Update enemies
        for enemy in enemies {
            enemy.updateAI(playerPosition: player.position, dt: dt)
        }

        // Spawn enemies
        enemySpawnTimer += dt
        if enemySpawnTimer >= enemySpawnInterval {
            enemySpawnTimer = 0
            spawnEnemy()
        }

        // Spawn powerups
        powerupSpawnTimer += dt
        if powerupSpawnTimer >= powerupSpawnInterval {
            powerupSpawnTimer = 0
            spawnPowerup()
        }

        // Weapon cooldown
        if weaponCooldown > 0 { weaponCooldown -= dt }

        // Delivery checks (distance-based backup)
        let pWorld = player.position
        _ = deliveryManager.checkPickup(playerWorldPos: pWorld)
        _ = deliveryManager.checkDelivery(playerWorldPos: pWorld)

        // Update navigation arrow
        deliveryManager.updateArrow(
            playerWorldPos: player.position,
            cameraPos: cameraNode.position,
            screenSize: size
        )

        // Update HUD
        hud.update(
            lives: lives,
            cash: gs.money,
            timeElapsed: timeElapsed,
            missionName: selectedMission?.description ?? "",
            weaponEmoji: gs.currentWeapon.emoji
        )

        // Remove dead enemies
        enemies = enemies.filter { $0.parent != nil }
    }

    // MARK: - Enemy Spawning

    private func spawnEnemy() {
        guard enemies.count < 12 else { return }

        // Spawn offscreen relative to player
        let angle = CGFloat.random(in: 0 ..< .pi * 2)
        let spawnRadius: CGFloat = 350
        let spawnX = player.position.x + cos(angle) * spawnRadius
        let spawnY = player.position.y + sin(angle) * spawnRadius

        let type: EnemyType
        let roll = Int.random(in: 0...10)
        if selectedMission?.hasCops == true && roll >= 9 {
            type = .police
        } else if roll >= 7 {
            type = .swervyCar
        } else {
            type = .saboteur
        }

        guard selectedMission?.hasSaboteurs == true || type == .swervyCar else { return }

        let enemy = Enemy(type: type)
        enemy.position = CGPoint(
            x: spawnX.clamped(to: -worldWidth/2 + 50 ... worldWidth/2 - 50),
            y: spawnY.clamped(to: -worldHeight/2 + 50 ... worldHeight/2 - 50)
        )
        enemy.zPosition = 8
        worldNode.addChild(enemy)
        enemies.append(enemy)
    }

    // MARK: - Powerup Spawning

    private func spawnPowerup() {
        let powerups = ["🍺", "🫕", "☕"]
        let type = powerups.randomElement()!
        let node = SpriteFactory.makePowerup(type: type)

        // Random spot near player on road
        node.position = CGPoint(
            x: player.position.x + CGFloat.random(in: -200...200),
            y: player.position.y + CGFloat.random(in: -200...200)
        )
        node.zPosition = 6
        node.name = "powerup_\(type)"

        let body = SKPhysicsBody(circleOfRadius: 18)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.powerup
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = 0
        node.physicsBody = body

        worldNode.addChild(node)

        // Auto-remove after 15s
        node.run(SKAction.sequence([
            SKAction.wait(forDuration: 15),
            SKAction.fadeOut(withDuration: 1),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Weapon Firing

    private func fireWeapon() {
        guard weaponCooldown <= 0 else { return }
        let cooldown = gs.currentWeapon == .fart ? 3.0 : (player.isRapidFire ? 0.2 : weaponCooldownBase)
        weaponCooldown = cooldown

        // Direction: forward in player facing direction
        let angle = player.spriteContainer.zRotation + .pi / 2
        let dir = CGVector(dx: cos(angle), dy: sin(angle))

        let weapon = Weapon(type: gs.currentWeapon, direction: dir)
        weapon.position = player.position
        weapon.zPosition = 9
        weapon.name = "weapon"
        worldNode.addChild(weapon)

        SoundManager.shared.playThrow()
    }

    // MARK: - Physics Contact

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA
        let b = contact.bodyB

        // Player hits enemy
        if (a.categoryBitMask == PhysicsCategory.player && b.categoryBitMask == PhysicsCategory.enemy) ||
           (a.categoryBitMask == PhysicsCategory.enemy  && b.categoryBitMask == PhysicsCategory.player) {
            let enemyBody = a.categoryBitMask == PhysicsCategory.enemy ? a : b
            if let enemyNode = enemyBody.node as? Enemy {
                playerHitByEnemy(enemy: enemyNode)
            }
        }

        // Weapon hits enemy
        if (a.categoryBitMask == PhysicsCategory.weapon && b.categoryBitMask == PhysicsCategory.enemy) ||
           (a.categoryBitMask == PhysicsCategory.enemy  && b.categoryBitMask == PhysicsCategory.weapon) {
            let wBody = a.categoryBitMask == PhysicsCategory.weapon ? a : b
            let eBody = a.categoryBitMask == PhysicsCategory.enemy  ? a : b
            if let weapon = wBody.node as? Weapon, let enemy = eBody.node as? Enemy {
                weaponHitEnemy(weapon: weapon, enemy: enemy, at: contact.contactPoint)
            }
        }

        // Player hits pickup/destination
        if (a.categoryBitMask == PhysicsCategory.player && b.categoryBitMask == PhysicsCategory.pickup) ||
           (a.categoryBitMask == PhysicsCategory.pickup  && b.categoryBitMask == PhysicsCategory.player) {
            let pickupBody = a.categoryBitMask == PhysicsCategory.pickup ? a : b
            if let pickupNode = pickupBody.node {
                handlePickupContact(node: pickupNode)
            }
        }

        // Player hits powerup
        if (a.categoryBitMask == PhysicsCategory.player  && b.categoryBitMask == PhysicsCategory.powerup) ||
           (a.categoryBitMask == PhysicsCategory.powerup && b.categoryBitMask == PhysicsCategory.player) {
            let puBody = a.categoryBitMask == PhysicsCategory.powerup ? a : b
            if let puNode = puBody.node {
                collectPowerup(node: puNode)
            }
        }
    }

    private func playerHitByEnemy(enemy: Enemy) {
        guard !player.isInvincible else { return }
        lives -= 1
        SoundManager.shared.playCrash()
        player.flashInvincibility(duration: 2.0)
        showPopup(text: "¡Ay no! -❤️", color: .red)

        // Screen shake
        let shake = SKAction.sequence([
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -20, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05)
        ])
        cameraNode.run(shake)

        if lives <= 0 { triggerGameOver() }
    }

    private func weaponHitEnemy(weapon: Weapon, enemy: Enemy, at contactPoint: CGPoint) {
        // Fart slows, doesn't kill immediately
        if weapon.weaponType == .fart {
            enemy.freeze(duration: 3.0)
            return
        }
        weapon.onHit(at: contactPoint, in: self)

        // Flash white on hit
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        enemy.run(flash)

        // POW! / BAM! hit effect
        let hitEffect = SpriteFactory.makeHitEffect(at: contactPoint)
        worldNode.addChild(hitEffect)

        let dead = enemy.takeDamage()
        if dead {
            gs.earnMoney(25)
            showPopup(text: "+$25", color: Colors.lineYellow)
        }
    }

    private func handlePickupContact(node: SKNode) {
        if node.name == "pickup" && !player.hasPackage {
            _ = deliveryManager.checkPickup(playerWorldPos: player.position)
        } else if node.name == "destination" && player.hasPackage {
            _ = deliveryManager.checkDelivery(playerWorldPos: player.position)
        }
    }

    private func collectPowerup(node: SKNode) {
        guard let name = node.name else { return }
        SoundManager.shared.playPowerup()

        if name.contains("🍺") {
            player.applySpeedBoost(duration: 10)
            player.flashInvincibility(duration: 3)
            showPopup(text: "🍺 PRESIDENTE! 🚀", color: Colors.yellow)
        } else if name.contains("🫕") {
            lives = min(3, lives + 1)
            showPopup(text: "🫕 Mangú +❤️", color: .green)
        } else if name.contains("☕") {
            player.isRapidFire = true
            showPopup(text: "☕ RAPID FIRE!", color: SKColor(red: 0.6, green: 0.3, blue: 0, alpha: 1))
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                self.player.isRapidFire = false
            }
        }

        node.removeFromParent()
    }

    // MARK: - Mission Complete / Game Over

    private func completeMission(reward: Int) {
        guard !missionComplete else { return }
        missionComplete = true
        player.deliverPackage()
        gs.earnMoney(reward)
        SoundManager.shared.playDeliver()
        showMissionCompleteOverlay(reward: reward)
    }

    private func triggerGameOver() {
        isGameOver = true
        showGameOverOverlay()
    }

    private func showMissionCompleteOverlay(reward: Int) {
        let overlay = buildOverlay(alpha: 0.92)
        cameraNode.addChild(overlay)

        // Mission complete title — arcade style
        let title = SKLabelNode(text: "MISION COMPLETA!")
        title.fontName = "Courier-Bold"; title.fontSize = 26; title.fontColor = Colors.lineYellow
        title.position = CGPoint(x: 0, y: 105)
        overlay.addChild(title)

        // Decorative divider
        let divider = SKShapeNode(rectOf: CGSize(width: 240, height: 3))
        divider.fillColor = Colors.playerOrange; divider.strokeColor = .clear
        divider.position = CGPoint(x: 0, y: 80)
        overlay.addChild(divider)

        let rewardLbl = SKLabelNode(text: "GANASTE: $\(reward)")
        rewardLbl.fontName = "Courier-Bold"; rewardLbl.fontSize = 20; rewardLbl.fontColor = Colors.gold
        rewardLbl.position = CGPoint(x: 0, y: 50)
        overlay.addChild(rewardLbl)

        let totalLbl = SKLabelNode(text: "TOTAL:  $\(gs.money)")
        totalLbl.fontName = "Courier-Bold"; totalLbl.fontSize = 16; totalLbl.fontColor = .white
        totalLbl.position = CGPoint(x: 0, y: 14)
        overlay.addChild(totalLbl)

        let shopBtn = SpriteFactory.makeButton(text: "TIENDA", size: CGSize(width: 148, height: 44),
                                               color: Colors.purple)
        shopBtn.position = CGPoint(x: -90, y: -55); shopBtn.name = "shopOverlay"
        overlay.addChild(shopBtn)

        let nextBtn = SpriteFactory.makeButton(text: "SIGUIENTE", size: CGSize(width: 148, height: 44),
                                               color: Colors.grassGreen)
        nextBtn.position = CGPoint(x: 90, y: -55); nextBtn.name = "nextMission"
        overlay.addChild(nextBtn)

        let menuBtn = SpriteFactory.makeButton(text: "MENU", size: CGSize(width: 120, height: 36),
                                               color: SKColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1))
        menuBtn.position = CGPoint(x: 0, y: -115); menuBtn.name = "mainMenu"
        overlay.addChild(menuBtn)

        overlay.name = "completeOverlay"
    }

    private func showGameOverOverlay() {
        let overlay = buildOverlay(alpha: 0.95)
        cameraNode.addChild(overlay)

        // GAME OVER — classic arcade red
        let title = SKLabelNode(text: "GAME OVER")
        title.fontName = "Courier-Bold"; title.fontSize = 44; title.fontColor = Colors.red
        title.position = CGPoint(x: 0, y: 105)
        overlay.addChild(title)

        // Shadow effect for title
        let titleShadow = SKLabelNode(text: "GAME OVER")
        titleShadow.fontName = "Courier-Bold"; titleShadow.fontSize = 44
        titleShadow.fontColor = SKColor(red: 0.4, green: 0.0, blue: 0.0, alpha: 1)
        titleShadow.position = CGPoint(x: 3, y: 102)
        overlay.addChild(titleShadow)
        overlay.addChild(title) // re-add on top

        let sub = SKLabelNode(text: "SE ACABO LA MISION, BRODER")
        sub.fontName = "Courier-Bold"; sub.fontSize = 14; sub.fontColor = .white
        sub.position = CGPoint(x: 0, y: 58)
        overlay.addChild(sub)

        // Score box
        let scoreBg = SKShapeNode(rectOf: CGSize(width: 200, height: 36))
        scoreBg.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.0, alpha: 0.9)
        scoreBg.strokeColor = Colors.gold; scoreBg.lineWidth = 2
        scoreBg.position = CGPoint(x: 0, y: 16)
        overlay.addChild(scoreBg)

        let scoreLbl = SKLabelNode(text: String(format: "SCORE: %06d", gs.score))
        scoreLbl.fontName = "Courier-Bold"; scoreLbl.fontSize = 18; scoreLbl.fontColor = Colors.gold
        scoreLbl.verticalAlignmentMode = .center; scoreLbl.position = CGPoint(x: 0, y: 16)
        overlay.addChild(scoreLbl)

        let retryBtn = SpriteFactory.makeButton(text: "REINTENTAR", size: CGSize(width: 175, height: 48),
                                                color: Colors.grassGreen)
        retryBtn.position = CGPoint(x: 0, y: -55); retryBtn.name = "retry"
        overlay.addChild(retryBtn)

        let menuBtn = SpriteFactory.makeButton(text: "MENU", size: CGSize(width: 140, height: 40),
                                               color: SKColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1))
        menuBtn.position = CGPoint(x: 0, y: -115); menuBtn.name = "mainMenu"
        overlay.addChild(menuBtn)

        overlay.name = "gameOverOverlay"
    }

    private func buildOverlay(alpha: CGFloat) -> SKNode {
        let n = SKNode(); n.zPosition = 200

        // Outer shadow
        let shadow = SKShapeNode(rectOf: CGSize(width: size.width * 0.86, height: size.height * 0.61))
        shadow.fillColor = .black; shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 3, y: -4)
        n.addChild(shadow)

        // Main panel — NES style (black bg, orange border)
        let bg = SKShapeNode(rectOf: CGSize(width: size.width * 0.85, height: size.height * 0.60))
        bg.fillColor = Colors.hudBlack.withAlphaComponent(alpha)
        bg.strokeColor = Colors.playerOrange; bg.lineWidth = 4
        n.addChild(bg)

        // Inner highlight border
        let inner = SKShapeNode(rectOf: CGSize(width: size.width * 0.82, height: size.height * 0.57))
        inner.fillColor = .clear
        inner.strokeColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.12); inner.lineWidth = 2
        n.addChild(inner)

        return n
    }

    private func showPopup(text: String, color: SKColor) {
        let popup = SpriteFactory.makeScorePopup(text: text, color: color)
        popup.position = CGPoint(x: CGFloat.random(in: -60...60), y: -50)
        cameraNode.addChild(popup)
    }

    // MARK: - HUD Delegate

    func hudDidTapFire() {
        fireWeapon()
    }

    func hudDidChangeWeapon(to delta: Int) {
        if delta > 0 { gs.nextWeapon() } else { gs.prevWeapon() }
    }

    func hudJoystickMoved(_ direction: CGVector) {
        joystickDirection = direction
    }

    func hudJoystickEnded() {
        joystickDirection = .zero
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let hudLoc = touch.location(in: hud)
            let handled = hud.handleTouchBegan(touch, in: self)

            if !handled {
                // Check overlay buttons
                let cameraLoc = touch.location(in: cameraNode)
                let cNodes = cameraNode.nodes(at: cameraLoc)
                for n in cNodes {
                    handleOverlayTap(name: n.name)
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            hud.handleTouchMoved(touch, in: self)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            hud.handleTouchEnded(touch, in: self)
        }
    }

    private func handleOverlayTap(name: String?) {
        switch name {
        case "retry":
            gs.reset()
            let scene = GameScene(size: size)
            scene.scaleMode = .aspectFill
            scene.selectedMission = selectedMission
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.4))
        case "mainMenu":
            let scene = MenuScene(size: size)
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
        case "nextMission":
            let scene = MissionSelectScene(size: size)
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.push(with: .left, duration: 0.4))
        case "shopOverlay":
            let scene = ShopScene(size: size)
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.push(with: .up, duration: 0.4))
        default: break
        }
    }
}

// MARK: - Comparable clamp helper

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
