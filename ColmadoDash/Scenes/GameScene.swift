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
        // Main roads (grid)
        let roadColor = Colors.road
        let sidewalkColor = Colors.sidewalk

        // Background ground
        let ground = SKShapeNode(rectOf: CGSize(width: worldWidth, height: worldHeight))
        ground.fillColor = sidewalkColor; ground.strokeColor = .clear
        ground.position = .zero
        worldNode.addChild(ground)

        // Horizontal roads
        for y in stride(from: -worldHeight/2, to: worldHeight/2, by: 300.0) {
            let road = SKShapeNode(rectOf: CGSize(width: worldWidth, height: 80))
            road.fillColor = roadColor; road.strokeColor = .clear
            road.position = CGPoint(x: 0, y: y)
            road.zPosition = 1
            worldNode.addChild(road)

            // Road markings
            for x in stride(from: -worldWidth/2, to: worldWidth/2, by: 60.0) {
                let mark = SKShapeNode(rectOf: CGSize(width: 30, height: 4))
                mark.fillColor = Colors.yellow.withAlphaComponent(0.7); mark.strokeColor = .clear
                mark.position = CGPoint(x: x, y: y)
                mark.zPosition = 2
                worldNode.addChild(mark)
            }
        }

        // Vertical roads
        for x in stride(from: -worldWidth/2, to: worldWidth/2, by: 300.0) {
            let road = SKShapeNode(rectOf: CGSize(width: 80, height: worldHeight))
            road.fillColor = roadColor; road.strokeColor = .clear
            road.position = CGPoint(x: x, y: 0)
            road.zPosition = 1
            worldNode.addChild(road)
        }
    }

    private func buildBuildings() {
        // Place buildings in the blocks between roads
        let buildingLabels = ["COLMADO", "FERRETERÍA", "BANCA", "FARMACIA", "TIENDA",
                              "BAR", "BARBERÍA", "PANADERÍA", "POLLERÍA", "EL CHINO"]
        var colorIdx = 0

        for blockY in stride(from: -worldHeight/2 + 180, to: worldHeight/2 - 150, by: 300.0) {
            for blockX in stride(from: -worldWidth/2 + 180, to: worldWidth/2 - 150, by: 300.0) {
                let bW = CGFloat.random(in: 80...140)
                let bH = CGFloat.random(in: 60...140)
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
        let dead = enemy.takeDamage()
        if dead {
            gs.earnMoney(25)
            showPopup(text: "+$25 💀", color: Colors.yellow)
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
        let overlay = buildOverlay(alpha: 0.88)
        cameraNode.addChild(overlay)

        let title = SKLabelNode(text: "🎉 ¡MISIÓN COMPLETADA!")
        title.fontName = "AvenirNext-Heavy"; title.fontSize = 28; title.fontColor = Colors.yellow
        title.position = CGPoint(x: 0, y: 100)
        overlay.addChild(title)

        let rewardLbl = SKLabelNode(text: "Ganaste: $\(reward)")
        rewardLbl.fontName = "AvenirNext-Bold"; rewardLbl.fontSize = 22; rewardLbl.fontColor = .white
        rewardLbl.position = CGPoint(x: 0, y: 50)
        overlay.addChild(rewardLbl)

        let totalLbl = SKLabelNode(text: "Total: $\(gs.money)")
        totalLbl.fontName = "AvenirNext-Bold"; totalLbl.fontSize = 18; totalLbl.fontColor = Colors.yellow
        totalLbl.position = CGPoint(x: 0, y: 10)
        overlay.addChild(totalLbl)

        let shopBtn = SpriteFactory.makeButton(text: "🛒 TIENDA", size: CGSize(width: 160, height: 44),
                                               color: SKColor(red: 0.5, green: 0.1, blue: 0.5, alpha: 1))
        shopBtn.position = CGPoint(x: -100, y: -60); shopBtn.name = "shopOverlay"
        overlay.addChild(shopBtn)

        let nextBtn = SpriteFactory.makeButton(text: "▶ SIGUIENTE", size: CGSize(width: 160, height: 44),
                                               color: SKColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1))
        nextBtn.position = CGPoint(x: 100, y: -60); nextBtn.name = "nextMission"
        overlay.addChild(nextBtn)

        let menuBtn = SpriteFactory.makeButton(text: "🏠 MENÚ", size: CGSize(width: 120, height: 36),
                                               color: SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1))
        menuBtn.position = CGPoint(x: 0, y: -120); menuBtn.name = "mainMenu"
        overlay.addChild(menuBtn)

        overlay.name = "completeOverlay"
    }

    private func showGameOverOverlay() {
        let overlay = buildOverlay(alpha: 0.92)
        cameraNode.addChild(overlay)

        let title = SKLabelNode(text: "💀 GAME OVER")
        title.fontName = "AvenirNext-Heavy"; title.fontSize = 40; title.fontColor = .red
        title.position = CGPoint(x: 0, y: 100)
        overlay.addChild(title)

        let sub = SKLabelNode(text: "Se acabó la misión, bróder")
        sub.fontName = "AvenirNext-Bold"; sub.fontSize = 16; sub.fontColor = .white
        sub.position = CGPoint(x: 0, y: 55)
        overlay.addChild(sub)

        let scoreLbl = SKLabelNode(text: "Puntuación: $\(gs.score)")
        scoreLbl.fontName = "AvenirNext-Bold"; scoreLbl.fontSize = 20; scoreLbl.fontColor = Colors.yellow
        scoreLbl.position = CGPoint(x: 0, y: 10)
        overlay.addChild(scoreLbl)

        let retryBtn = SpriteFactory.makeButton(text: "🔄 REINTENTAR", size: CGSize(width: 180, height: 48),
                                                color: SKColor(red: 0.1, green: 0.55, blue: 0.1, alpha: 1))
        retryBtn.position = CGPoint(x: 0, y: -60); retryBtn.name = "retry"
        overlay.addChild(retryBtn)

        let menuBtn = SpriteFactory.makeButton(text: "🏠 MENÚ", size: CGSize(width: 140, height: 40),
                                               color: SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1))
        menuBtn.position = CGPoint(x: 0, y: -120); menuBtn.name = "mainMenu"
        overlay.addChild(menuBtn)

        overlay.name = "gameOverOverlay"
    }

    private func buildOverlay(alpha: CGFloat) -> SKNode {
        let n = SKNode(); n.zPosition = 200
        let bg = SKShapeNode(rectOf: CGSize(width: size.width * 0.85, height: size.height * 0.6),
                             cornerRadius: 16)
        bg.fillColor = Colors.hudBG.withAlphaComponent(alpha)
        bg.strokeColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.4); bg.lineWidth = 2
        n.addChild(bg)
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
