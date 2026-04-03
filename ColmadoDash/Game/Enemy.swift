// Enemy.swift — Colmado Dash
// Enemy types: Saboteur pedestrian, Swervy car, Police

import SpriteKit

enum EnemyType {
    case saboteur
    case swervyCar
    case police
}

class Enemy: SKNode {
    let enemyType: EnemyType
    var health: Int
    var isFrozen = false
    var frozenTimer: TimeInterval = 0
    private var visualNode: SKNode!

    init(type: EnemyType) {
        self.enemyType = type
        self.health = type == .police ? 3 : 1
        super.init()
        setupVisual()
        setupPhysics()
        setupAI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setupVisual() {
        switch enemyType {
        case .saboteur:
            visualNode = SpriteFactory.makeEnemy()
        case .swervyCar:
            let car = SKShapeNode(rectOf: CGSize(width: 40, height: 20), cornerRadius: 4)
            car.fillColor = SKColor(red: 0.7, green: 0.1, blue: 0.1, alpha: 1)
            car.strokeColor = .black; car.lineWidth = 1.5
            let wheels = SKNode()
            for (x, y): (CGFloat, CGFloat) in [(-16, -6), (16, -6), (-16, 6), (16, 6)] {
                let w = SKShapeNode(circleOfRadius: 6)
                w.fillColor = .darkGray; w.position = CGPoint(x: x, y: y)
                wheels.addChild(w)
            }
            let n = SKNode()
            n.addChild(car); n.addChild(wheels)
            visualNode = n
        case .police:
            visualNode = SpriteFactory.makeCopCar()
        }
        addChild(visualNode)
    }

    private func setupPhysics() {
        let radius: CGFloat = enemyType == .saboteur ? 14 : 20
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.categoryBitMask    = PhysicsCategory.enemy
        body.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.weapon
        body.collisionBitMask   = PhysicsCategory.building
        body.allowsRotation     = false
        body.linearDamping      = 3.0
        self.physicsBody        = body
    }

    private func setupAI() {
        switch enemyType {
        case .swervyCar:
            // Swerve pattern
            let swerve = SKAction.sequence([
                SKAction.moveBy(x: 30, y: 0, duration: 0.8),
                SKAction.moveBy(x: -30, y: 0, duration: 0.8)
            ])
            run(SKAction.repeatForever(swerve))
        default:
            break
        }
    }

    func updateAI(playerPosition: CGPoint, dt: TimeInterval) {
        guard !isFrozen else { return }
        guard let body = physicsBody else { return }

        let dx = playerPosition.x - position.x
        let dy = playerPosition.y - position.y
        let dist = sqrt(dx*dx + dy*dy)
        guard dist > 5 else { return }

        let speed: CGFloat
        switch enemyType {
        case .saboteur:  speed = 80
        case .swervyCar: speed = 140
        case .police:    speed = 160
        }

        let nx = dx / dist
        let ny = dy / dist
        body.velocity = CGVector(dx: nx * speed, dy: ny * speed)

        // Face direction
        let angle = atan2(ny, nx) - .pi / 2
        let rot = SKAction.rotate(toAngle: angle, duration: 0.1, shortestUnitArc: true)
        visualNode.run(rot)
    }

    func freeze(duration: TimeInterval) {
        isFrozen = true
        physicsBody?.velocity = .zero
        // Blue tint
        let tint = SKAction.colorize(with: .cyan, colorBlendFactor: 0.7, duration: 0.2)
        visualNode.run(tint)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isFrozen = false
            let untint = SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 0.3)
            self.visualNode.run(untint)
        }
    }

    func takeDamage(_ amount: Int = 1) -> Bool {
        health -= amount
        // Flash red
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.9, duration: 0.05),
            SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 0.15)
        ])
        visualNode.run(flash)
        if health <= 0 {
            explode()
            return true // dead
        }
        return false
    }

    private func explode() {
        // Particle burst
        for _ in 0..<8 {
            let spark = SKShapeNode(circleOfRadius: 4)
            spark.fillColor = [SKColor.yellow, SKColor.orange, SKColor.red].randomElement()!
            spark.position = position
            parent?.addChild(spark)
            let dx = CGFloat.random(in: -60...60)
            let dy = CGFloat.random(in: -60...60)
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.4)
            let fade = SKAction.fadeOut(withDuration: 0.4)
            spark.run(SKAction.sequence([SKAction.group([move, fade]), SKAction.removeFromParent()]))
        }
        removeFromParent()
    }
}
