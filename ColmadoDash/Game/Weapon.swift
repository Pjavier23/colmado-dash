// Weapon.swift — Colmado Dash
// Throwable weapon nodes with different physics behaviors

import SpriteKit

class Weapon: SKNode {
    let weaponType: WeaponType
    var hasHit = false

    init(type: WeaponType, direction: CGVector) {
        self.weaponType = type
        super.init()
        setupVisual()
        setupPhysics()
        launch(direction: direction)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setupVisual() {
        let lbl = SKLabelNode(text: weaponType.emoji)
        lbl.fontSize = 22
        lbl.verticalAlignmentMode = .center
        addChild(lbl)

        // Spin while in flight
        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 0.4)
        lbl.run(SKAction.repeatForever(spin))
    }

    private func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: 10)
        body.categoryBitMask    = PhysicsCategory.weapon
        body.contactTestBitMask = PhysicsCategory.enemy
        body.collisionBitMask   = 0
        body.affectedByGravity  = weaponType == .salami // only salami arcs
        body.allowsRotation     = true
        self.physicsBody        = body
    }

    private func launch(direction: CGVector) {
        let speed: CGFloat
        switch weaponType {
        case .platano: speed = 350
        case .huevo:   speed = 400
        case .salami:  speed = 300
        case .fart:    speed = 0
        }

        physicsBody?.velocity = CGVector(dx: direction.dx * speed, dy: direction.dy * speed)

        switch weaponType {
        case .platano:
            launchBoomerang(direction: direction)
        case .salami:
            physicsBody?.applyImpulse(CGVector(dx: direction.dx * 3, dy: direction.dy * 3 + 4))
        case .fart:
            setupFartCloud()
        default:
            break
        }

        // Auto-remove after lifetime
        let lifetime: TimeInterval = weaponType == .fart ? 3.0 : 2.5
        run(SKAction.sequence([
            SKAction.wait(forDuration: lifetime),
            SKAction.removeFromParent()
        ]))
    }

    private func launchBoomerang(direction: CGVector) {
        // Boomerang: fly forward then curve back
        guard let body = physicsBody else { return }
        let curveSequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.run { [weak self] in
                guard let self = self, let b = self.physicsBody else { return }
                // Reverse + curve
                b.velocity = CGVector(dx: -b.velocity.dx * 0.8, dy: -b.velocity.dy * 0.8)
            }
        ])
        run(curveSequence)
    }

    private func setupFartCloud() {
        physicsBody?.velocity = .zero
        // Green cloud visual
        for i in 0..<5 {
            let cloud = SKShapeNode(circleOfRadius: CGFloat.random(in: 12...22))
            cloud.fillColor = SKColor(red: 0.4, green: 0.8, blue: 0.3, alpha: 0.35)
            cloud.strokeColor = .clear
            cloud.position = CGPoint(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: -20...20))
            cloud.zPosition = CGFloat(i)
            addChild(cloud)
            let drift = SKAction.moveBy(x: CGFloat.random(in: -10...10), y: CGFloat.random(in: 5...15), duration: 1.5)
            let fade = SKAction.sequence([SKAction.wait(forDuration: 1.5), SKAction.fadeOut(withDuration: 1.5)])
            cloud.run(SKAction.group([drift, fade]))
        }
        // Expand hitbox over time for fart area
        let expand = SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.run { [weak self] in
                self?.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
            }
        ])
        run(expand)
    }

    // Called when weapon hits an enemy
    func onHit(at position: CGPoint, in scene: SKScene) {
        guard !hasHit || weaponType == .fart else { return }
        if weaponType != .fart { hasHit = true }

        switch weaponType {
        case .huevo:
            spawnSlimePool(at: position, in: scene)
            removeFromParent()
        case .salami:
            spawnExplosion(at: position, in: scene)
            removeFromParent()
        case .fart:
            break // stays in place
        default:
            break
        }
    }

    private func spawnSlimePool(at pos: CGPoint, in scene: SKScene) {
        let pool = SKShapeNode(circleOfRadius: 25)
        pool.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 0.6)
        pool.strokeColor = SKColor(red: 0.1, green: 0.6, blue: 0.2, alpha: 1)
        pool.lineWidth = 2
        pool.position = pos
        pool.zPosition = 1
        scene.addChild(pool)

        // Slime pool physics (slow enemies walking through)
        let slimeBody = SKPhysicsBody(circleOfRadius: 25)
        slimeBody.isDynamic = false
        slimeBody.categoryBitMask = PhysicsCategory.weapon
        slimeBody.contactTestBitMask = PhysicsCategory.enemy
        pool.physicsBody = slimeBody

        pool.run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }

    private func spawnExplosion(at pos: CGPoint, in scene: SKScene) {
        // Big boom circle
        let boom = SKShapeNode(circleOfRadius: 5)
        boom.fillColor = SKColor(red: 1, green: 0.6, blue: 0.0, alpha: 0.9)
        boom.strokeColor = .clear
        boom.position = pos
        boom.zPosition = 5
        scene.addChild(boom)
        boom.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 8, duration: 0.25),
                SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.7, duration: 0.1),
                    SKAction.fadeOut(withDuration: 0.15)
                ])
            ]),
            SKAction.removeFromParent()
        ]))
        // Sparks
        for _ in 0..<12 {
            let spark = SKShapeNode(circleOfRadius: 3)
            spark.fillColor = [SKColor.yellow, SKColor.orange, SKColor.red].randomElement()!
            spark.position = pos
            scene.addChild(spark)
            let dx = CGFloat.random(in: -80...80)
            let dy = CGFloat.random(in: -80...80)
            spark.run(SKAction.sequence([
                SKAction.group([
                    SKAction.moveBy(x: dx, y: dy, duration: 0.5),
                    SKAction.fadeOut(withDuration: 0.5)
                ]),
                SKAction.removeFromParent()
            ]))
        }
        SoundManager.shared.playHit()
    }
}
