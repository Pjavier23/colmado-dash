// HUD.swift — Colmado Dash
// HUD overlay: hearts, cash, timer, mission name, joystick, buttons

import SpriteKit

protocol HUDDelegate: AnyObject {
    func hudDidTapFire()
    func hudDidChangeWeapon(to index: Int)
    func hudJoystickMoved(_ direction: CGVector)
    func hudJoystickEnded()
}

class HUD: SKNode {
    weak var delegate: HUDDelegate?

    // UI references
    private var heartNodes: [SKLabelNode] = []
    private var cashLabel: SKLabelNode!
    private var timerLabel: SKLabelNode!
    private var missionLabel: SKLabelNode!
    private var weaponLabel: SKLabelNode!
    private var topBar: SKShapeNode!

    // Joystick
    private var joystickBase: SKShapeNode!
    private var joystickKnob: SKShapeNode!
    private var joystickCenter: CGPoint = .zero
    private var joystickActive = false
    private var joystickTouchId: UITouch?

    // Fire button
    private var fireButton: SKShapeNode!
    private var prevWeaponBtn: SKNode!
    private var nextWeaponBtn: SKNode!

    private let screenSize: CGSize

    init(size: CGSize) {
        self.screenSize = size
        super.init()
        zPosition = 100
        buildHUD()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func buildHUD() {
        buildTopBar()
        buildJoystick()
        buildFireButton()
        buildWeaponSelector()
    }

    private func buildTopBar() {
        let barHeight: CGFloat = 50
        topBar = SKShapeNode(rectOf: CGSize(width: screenSize.width, height: barHeight))
        topBar.fillColor = Colors.hudBG
        topBar.strokeColor = .clear
        topBar.position = CGPoint(x: 0, y: screenSize.height / 2 - barHeight / 2)
        addChild(topBar)

        // Hearts
        for i in 0..<3 {
            let h = SKLabelNode(text: "❤️")
            h.fontSize = 20
            h.position = CGPoint(x: CGFloat(i) * 28 - screenSize.width / 2 + 30, y: -8)
            topBar.addChild(h)
            heartNodes.append(h)
        }

        // Cash
        cashLabel = SKLabelNode(text: "$0")
        cashLabel.fontName = "AvenirNext-Bold"
        cashLabel.fontSize = 18; cashLabel.fontColor = Colors.yellow
        cashLabel.position = CGPoint(x: -60, y: -8)
        cashLabel.verticalAlignmentMode = .center
        topBar.addChild(cashLabel)

        // Timer
        timerLabel = SKLabelNode(text: "⏱ 0:00")
        timerLabel.fontName = "AvenirNext-Bold"
        timerLabel.fontSize = 16; timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: 60, y: -8)
        timerLabel.verticalAlignmentMode = .center
        topBar.addChild(timerLabel)

        // Mission name
        missionLabel = SKLabelNode(text: "Misión")
        missionLabel.fontName = "AvenirNext-Bold"
        missionLabel.fontSize = 12; missionLabel.fontColor = SKColor(red: 0.8, green: 0.8, blue: 1, alpha: 1)
        missionLabel.position = CGPoint(x: screenSize.width / 2 - 80, y: -8)
        missionLabel.verticalAlignmentMode = .center
        topBar.addChild(missionLabel)
    }

    private func buildJoystick() {
        // Base
        joystickBase = SKShapeNode(circleOfRadius: 55)
        joystickBase.fillColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.12)
        joystickBase.strokeColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        joystickBase.lineWidth = 2
        joystickBase.position = CGPoint(x: -screenSize.width / 2 + 90, y: -screenSize.height / 2 + 100)
        joystickCenter = joystickBase.position
        addChild(joystickBase)

        // Knob
        joystickKnob = SKShapeNode(circleOfRadius: 28)
        joystickKnob.fillColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.35)
        joystickKnob.strokeColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        joystickKnob.lineWidth = 2
        joystickKnob.position = joystickCenter
        addChild(joystickKnob)
    }

    private func buildFireButton() {
        fireButton = SKShapeNode(circleOfRadius: 44)
        fireButton.fillColor = SKColor(red: 0.85, green: 0.1, blue: 0.1, alpha: 0.75)
        fireButton.strokeColor = SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1)
        fireButton.lineWidth = 2.5
        fireButton.name = "fireButton"
        fireButton.position = CGPoint(x: screenSize.width / 2 - 80, y: -screenSize.height / 2 + 100)
        addChild(fireButton)

        let fireLbl = SKLabelNode(text: "🔥")
        fireLbl.fontSize = 28; fireLbl.verticalAlignmentMode = .center
        fireLbl.name = "fireButton"
        fireButton.addChild(fireLbl)
    }

    private func buildWeaponSelector() {
        weaponLabel = SKLabelNode(text: "🍌")
        weaponLabel.fontSize = 24
        weaponLabel.position = CGPoint(x: screenSize.width / 2 - 80, y: -screenSize.height / 2 + 175)
        addChild(weaponLabel)

        // Prev / Next buttons
        let prev = SpriteFactory.makeButton(text: "◀", size: CGSize(width: 36, height: 28),
                                            color: SKColor(red: 0, green: 0, blue: 0, alpha: 0.5))
        prev.position = CGPoint(x: screenSize.width / 2 - 120, y: -screenSize.height / 2 + 175)
        prev.name = "prevWeapon"
        addChild(prev)
        prevWeaponBtn = prev

        let next = SpriteFactory.makeButton(text: "▶", size: CGSize(width: 36, height: 28),
                                            color: SKColor(red: 0, green: 0, blue: 0, alpha: 0.5))
        next.position = CGPoint(x: screenSize.width / 2 - 40, y: -screenSize.height / 2 + 175)
        next.name = "nextWeapon"
        addChild(next)
        nextWeaponBtn = next
    }

    // MARK: - Update calls

    func update(lives: Int, cash: Int, timeElapsed: TimeInterval, missionName: String, weaponEmoji: String) {
        // Hearts
        for (i, h) in heartNodes.enumerated() {
            h.text = i < lives ? "❤️" : "🖤"
        }
        cashLabel.text = "$\(cash)"
        let mins = Int(timeElapsed) / 60
        let secs = Int(timeElapsed) % 60
        timerLabel.text = String(format: "⏱ %d:%02d", mins, secs)
        missionLabel.text = missionName
        weaponLabel.text = weaponEmoji
    }

    // MARK: - Touch handling

    func handleTouchBegan(_ touch: UITouch, in scene: SKScene) -> Bool {
        let loc = touch.location(in: self)

        // Fire button
        let fireNodes = nodes(at: loc)
        if fireNodes.contains(where: { $0.name == "fireButton" }) {
            animateFireButton()
            delegate?.hudDidTapFire()
            return true
        }
        if fireNodes.contains(where: { $0.name == "prevWeapon" }) {
            delegate?.hudDidChangeWeapon(to: -1)
            return true
        }
        if fireNodes.contains(where: { $0.name == "nextWeapon" }) {
            delegate?.hudDidChangeWeapon(to: 1)
            return true
        }

        // Joystick
        let distToJoy = distance(loc, joystickCenter)
        if distToJoy < 80 {
            joystickActive = true
            joystickTouchId = touch
            updateJoystick(at: loc)
            return true
        }
        return false
    }

    func handleTouchMoved(_ touch: UITouch, in scene: SKScene) {
        guard joystickActive, touch === joystickTouchId else { return }
        let loc = touch.location(in: self)
        updateJoystick(at: loc)
    }

    func handleTouchEnded(_ touch: UITouch, in scene: SKScene) {
        guard touch === joystickTouchId else { return }
        joystickActive = false
        joystickTouchId = nil
        joystickKnob.run(SKAction.move(to: joystickCenter, duration: 0.1))
        delegate?.hudJoystickEnded()
    }

    private func updateJoystick(at loc: CGPoint) {
        let dx = loc.x - joystickCenter.x
        let dy = loc.y - joystickCenter.y
        let dist = sqrt(dx*dx + dy*dy)
        let maxRadius: CGFloat = 45

        if dist <= maxRadius {
            joystickKnob.position = loc
        } else {
            let nx = dx / dist
            let ny = dy / dist
            joystickKnob.position = CGPoint(x: joystickCenter.x + nx * maxRadius,
                                             y: joystickCenter.y + ny * maxRadius)
        }

        let normalized = CGVector(dx: dx / max(dist, 1) * min(dist / maxRadius, 1),
                                  dy: dy / max(dist, 1) * min(dist / maxRadius, 1))
        delegate?.hudJoystickMoved(normalized)
    }

    private func animateFireButton() {
        let pop = SKAction.sequence([
            SKAction.scale(to: 0.85, duration: 0.07),
            SKAction.scale(to: 1.0, duration: 0.07)
        ])
        fireButton.run(pop)
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x; let dy = a.y - b.y
        return sqrt(dx*dx + dy*dy)
    }
}
