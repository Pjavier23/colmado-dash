// Delivery.swift — Colmado Dash
// Mission/delivery logic: pickup zones, destination zones, arrow navigation

import SpriteKit

enum DeliveryState {
    case goPickup
    case goDeliver
    case complete
}

class DeliveryManager {
    weak var scene: SKScene?
    let mission: MissionData

    var state: DeliveryState = .goPickup
    var pickupNode: SKNode!
    var destinationNode: SKNode!
    var navArrow: SKLabelNode!

    // World positions (relative to world node)
    let pickupPosition = CGPoint(x: -200, y: 300)
    let deliverPosition = CGPoint(x: 400, y: -200)

    var onComplete: ((Int) -> Void)?
    var onPickup:   (() -> Void)?

    init(mission: MissionData, scene: SKScene) {
        self.mission = mission
        self.scene   = scene
        setup()
    }

    private func setup() {
        guard let scene = scene else { return }

        // Find world node
        let world = scene.childNode(withName: "world") ?? scene

        // Pickup marker
        pickupNode = SpriteFactory.makePickupMarker(label: mission.pickupName)
        pickupNode.position = pickupPosition
        pickupNode.zPosition = 5

        let pickupBody = SKPhysicsBody(circleOfRadius: 30)
        pickupBody.isDynamic = false
        pickupBody.categoryBitMask = PhysicsCategory.pickup
        pickupBody.contactTestBitMask = PhysicsCategory.player
        pickupBody.collisionBitMask = 0
        pickupNode.physicsBody = pickupBody
        pickupNode.name = "pickup"
        world.addChild(pickupNode)

        // Destination marker (hidden until package picked up)
        destinationNode = SpriteFactory.makeDestinationMarker(label: mission.dropoffName)
        destinationNode.position = deliverPosition
        destinationNode.zPosition = 5
        destinationNode.isHidden = true

        let destBody = SKPhysicsBody(circleOfRadius: 30)
        destBody.isDynamic = false
        destBody.categoryBitMask = PhysicsCategory.pickup
        destBody.contactTestBitMask = PhysicsCategory.player
        destBody.collisionBitMask = 0
        destinationNode.physicsBody = destBody
        destinationNode.name = "destination"
        world.addChild(destinationNode)

        // Navigation arrow (stays on screen)
        navArrow = SKLabelNode(text: "➡️")
        navArrow.fontSize = 28
        navArrow.zPosition = 50
        scene.addChild(navArrow)
    }

    func updateArrow(playerWorldPos: CGPoint, cameraPos: CGPoint, screenSize: CGSize) {
        let target: CGPoint
        switch state {
        case .goPickup:  target = pickupPosition
        case .goDeliver: target = deliverPosition
        case .complete:  navArrow.isHidden = true; return
        }

        let dx = target.x - playerWorldPos.x
        let dy = target.y - playerWorldPos.y
        let angle = atan2(dy, dx)

        // Position arrow at edge of screen in direction of target
        let dist = sqrt(dx*dx + dy*dy)
        let radius: CGFloat = min(screenSize.width, screenSize.height) * 0.38
        let arrowX = cos(angle) * radius
        let arrowY = sin(angle) * radius

        navArrow.position = CGPoint(x: arrowX, y: arrowY)
        navArrow.zRotation = angle - .pi / 2

        // Hide arrow if close to target
        navArrow.isHidden = dist < 120
    }

    func checkPickup(playerWorldPos: CGPoint) -> Bool {
        guard state == .goPickup else { return false }
        let dx = playerWorldPos.x - pickupPosition.x
        let dy = playerWorldPos.y - pickupPosition.y
        let dist = sqrt(dx*dx + dy*dy)
        if dist < 50 {
            state = .goDeliver
            pickupNode.run(SKAction.sequence([
                SKAction.scale(to: 1.3, duration: 0.1),
                SKAction.scale(to: 0, duration: 0.2),
                SKAction.removeFromParent()
            ]))
            destinationNode.isHidden = false
            onPickup?()
            return true
        }
        return false
    }

    func checkDelivery(playerWorldPos: CGPoint) -> Bool {
        guard state == .goDeliver else { return false }
        let dx = playerWorldPos.x - deliverPosition.x
        let dy = playerWorldPos.y - deliverPosition.y
        let dist = sqrt(dx*dx + dy*dy)
        if dist < 60 {
            state = .complete
            navArrow.isHidden = true
            destinationNode.run(SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.15),
                SKAction.scale(to: 0, duration: 0.2),
                SKAction.removeFromParent()
            ]))
            onComplete?(mission.reward)
            return true
        }
        return false
    }

    func cleanup() {
        pickupNode?.removeFromParent()
        destinationNode?.removeFromParent()
        navArrow?.removeFromParent()
    }
}
