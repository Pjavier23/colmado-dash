// Player.swift — Colmado Dash
// Player node: vehicle sprite + physics + movement

import SpriteKit

class Player: SKNode {
    var vehicleType: VehicleType
    var spriteContainer: SKNode!
    var hasPackage = false
    private var packageNode: SKNode?
    var isInvincible = false
    var speedMultiplier: CGFloat = 1.0
    var isRapidFire = false

    init(vehicleType: VehicleType) {
        self.vehicleType = vehicleType
        super.init()
        setupSprite()
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setupSprite() {
        spriteContainer?.removeFromParent()
        spriteContainer = SpriteFactory.makePlayer(type: vehicleType)
        addChild(spriteContainer)
    }

    private func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: 18)
        body.categoryBitMask    = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.pickup | PhysicsCategory.powerup
        body.collisionBitMask   = PhysicsCategory.building
        body.allowsRotation     = false
        body.linearDamping      = 4.0
        body.mass               = 1.0
        self.physicsBody        = body
    }

    func upgrade(to type: VehicleType) {
        vehicleType = type
        setupSprite()
        if hasPackage { showPackage() }
    }

    func pickUpPackage() {
        hasPackage = true
        showPackage()
        SoundManager.shared.playPickup()
    }

    func deliverPackage() {
        hasPackage = false
        packageNode?.removeFromParent()
        packageNode = nil
        SoundManager.shared.playDeliver()
    }

    private func showPackage() {
        packageNode?.removeFromParent()
        let pkg = SpriteFactory.makePackage()
        pkg.position = CGPoint(x: 0, y: 20)
        pkg.zPosition = 2
        addChild(pkg)
        packageNode = pkg
        // Wobble
        let wobble = SKAction.sequence([
            SKAction.rotate(byAngle: 0.1, duration: 0.1),
            SKAction.rotate(byAngle: -0.2, duration: 0.2),
            SKAction.rotate(byAngle: 0.1, duration: 0.1)
        ])
        pkg.run(SKAction.repeatForever(wobble))
    }

    func move(direction: CGVector) {
        guard let body = physicsBody else { return }
        let baseSpeed = vehicleType.speed * speedMultiplier
        let force = CGVector(dx: direction.dx * baseSpeed * 10,
                             dy: direction.dy * baseSpeed * 10)
        body.applyForce(force)

        // Face direction of movement
        if direction.dx != 0 || direction.dy != 0 {
            let angle = atan2(direction.dy, direction.dx) - .pi / 2
            let rotate = SKAction.rotate(toAngle: angle, duration: 0.15, shortestUnitArc: true)
            spriteContainer.run(rotate)
        }
    }

    func flashInvincibility(duration: TimeInterval) {
        isInvincible = true
        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        run(SKAction.repeat(flash, count: Int(duration / 0.2)))
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isInvincible = false
            self.alpha = 1.0
        }
    }

    func applySpeedBoost(duration: TimeInterval) {
        speedMultiplier = 1.8
        // Golden glow
        let glow = SKShapeNode(circleOfRadius: 25)
        glow.fillColor = SKColor(red: 1, green: 0.9, blue: 0, alpha: 0.25)
        glow.strokeColor = SKColor(red: 1, green: 0.85, blue: 0, alpha: 0.8)
        glow.lineWidth = 2; glow.name = "boostGlow"
        addChild(glow)
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.3),
            SKAction.scale(to: 0.9, duration: 0.3)
        ])
        glow.run(SKAction.repeatForever(pulse))
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.speedMultiplier = 1.0
            self.childNode(withName: "boostGlow")?.removeFromParent()
        }
    }
}
