// HUD.swift — Colmado Dash
// 8-bit Arcade style HUD: pixel art hearts, arcade score, joystick, buttons

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
    private var scoreLabel: SKLabelNode!
    private var timerBox: SKShapeNode!
    private var timerLabel: SKLabelNode!
    private var missionLabel: SKLabelNode!
    private var weaponSlot: SKShapeNode!
    private var weaponLabel: SKLabelNode!
    private var topBar: SKShapeNode!
    private var p1Badge: SKNode!

    // Joystick
    private var joystickBase: SKShapeNode!
    private var joystickKnob: SKShapeNode!
    private var joystickCenter: CGPoint = .zero
    private var joystickActive = false
    private var joystickTouchId: UITouch?

    // Buttons
    private var fireButton: SKNode!
    private var prevWeaponBtn: SKNode!
    private var nextWeaponBtn: SKNode!
    private var fireButtonShape: SKShapeNode!

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

    // MARK: - Top Bar (arcade style)

    private func buildTopBar() {
        let barH: CGFloat = 52

        // Black bar with ORANGE border
        topBar = SKShapeNode(rectOf: CGSize(width: screenSize.width, height: barH))
        topBar.fillColor = Colors.hudBlack
        topBar.strokeColor = Colors.playerOrange; topBar.lineWidth = 3
        topBar.position = CGPoint(x: 0, y: screenSize.height / 2 - barH / 2)
        addChild(topBar)

        // P1 badge
        let p1Bg = SKShapeNode(rectOf: CGSize(width: 28, height: 18))
        p1Bg.fillColor = Colors.playerOrange; p1Bg.strokeColor = .black; p1Bg.lineWidth = 2
        p1Bg.position = CGPoint(x: -screenSize.width / 2 + 20, y: 0)
        topBar.addChild(p1Bg)

        let p1Lbl = SKLabelNode(text: "P1")
        p1Lbl.fontName = "Courier-Bold"; p1Lbl.fontSize = 11
        p1Lbl.fontColor = .black; p1Lbl.verticalAlignmentMode = .center
        p1Lbl.position = CGPoint(x: -screenSize.width / 2 + 20, y: 0)
        topBar.addChild(p1Lbl)

        // Hearts — ♥ symbols in bright red
        let heartStartX = -screenSize.width / 2 + 50
        for i in 0..<3 {
            let h = SKLabelNode(text: "❤️")
            h.fontSize = 18
            h.position = CGPoint(x: heartStartX + CGFloat(i) * 26, y: 0)
            h.verticalAlignmentMode = .center
            topBar.addChild(h)
            heartNodes.append(h)
        }

        // Score — arcade style "SCORE: 000000" left-padded with zeros
        scoreLabel = SKLabelNode(text: "SCORE:000000")
        scoreLabel.fontName = "Courier-Bold"; scoreLabel.fontSize = 14
        scoreLabel.fontColor = Colors.lineYellow
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: -50, y: 0)
        topBar.addChild(scoreLabel)

        // Timer in red box
        timerBox = SKShapeNode(rectOf: CGSize(width: 72, height: 26))
        timerBox.fillColor = Colors.red; timerBox.strokeColor = .black; timerBox.lineWidth = 2
        timerBox.position = CGPoint(x: screenSize.width / 2 - 50, y: 0)
        topBar.addChild(timerBox)

        timerLabel = SKLabelNode(text: "0:00")
        timerLabel.fontName = "Courier-Bold"; timerLabel.fontSize = 14
        timerLabel.fontColor = .white; timerLabel.verticalAlignmentMode = .center
        timerLabel.position = CGPoint(x: screenSize.width / 2 - 50, y: 0)
        topBar.addChild(timerLabel)

        // Mission label
        missionLabel = SKLabelNode(text: "MISIÓN")
        missionLabel.fontName = "Courier-Bold"; missionLabel.fontSize = 10
        missionLabel.fontColor = SKColor(red: 0.8, green: 0.8, blue: 1, alpha: 1)
        missionLabel.verticalAlignmentMode = .center
        missionLabel.position = CGPoint(x: screenSize.width / 2 - 120, y: -13)
        topBar.addChild(missionLabel)
    }

    // MARK: - Joystick (arcade style)

    private func buildJoystick() {
        let center = CGPoint(x: -screenSize.width / 2 + 90, y: -screenSize.height / 2 + 100)
        joystickCenter = center

        // Outer ring — dark gray with orange border
        joystickBase = SKShapeNode(circleOfRadius: 55)
        joystickBase.fillColor = SKColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 0.88)
        joystickBase.strokeColor = Colors.playerOrange; joystickBase.lineWidth = 3
        joystickBase.position = center
        addChild(joystickBase)

        // Direction indicators — small arrow triangles at N/S/E/W
        let arrowPositions: [(CGFloat, CGFloat, CGFloat)] = [
            (0, 42, 0),           // N
            (0, -42, .pi),        // S
            (42, 0, .pi / 2),     // E (left = negative x, right = positive)
            (-42, 0, -.pi / 2)    // W
        ]
        for (dx, dy, rot) in arrowPositions {
            let arrow = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 5))
            path.addLine(to: CGPoint(x: -5, y: -5))
            path.addLine(to: CGPoint(x: 5, y: -5))
            path.closeSubpath()
            arrow.path = path
            arrow.fillColor = Colors.playerOrange.withAlphaComponent(0.6)
            arrow.strokeColor = .clear
            arrow.position = CGPoint(x: center.x + dx, y: center.y + dy)
            arrow.zRotation = rot
            addChild(arrow)
        }

        // Inner pad — slightly lighter gray
        joystickKnob = SKShapeNode(circleOfRadius: 28)
        joystickKnob.fillColor = SKColor(red: 0.32, green: 0.32, blue: 0.32, alpha: 0.92)
        joystickKnob.strokeColor = Colors.playerOrange; joystickKnob.lineWidth = 2
        joystickKnob.position = center
        addChild(joystickKnob)
    }

    // MARK: - Fire Button (arcade style)

    private func buildFireButton() {
        let center = CGPoint(x: screenSize.width / 2 - 80, y: -screenSize.height / 2 + 100)

        let root = SKNode()
        root.position = center
        root.name = "fireButton"
        addChild(root)
        fireButton = root

        // Shadow for 3D effect
        let shadow = SKShapeNode(circleOfRadius: 44)
        shadow.fillColor = .black; shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -3)
        root.addChild(shadow)

        // Main button — RED with thick black outline
        fireButtonShape = SKShapeNode(circleOfRadius: 44)
        fireButtonShape.fillColor = Colors.red
        fireButtonShape.strokeColor = .black; fireButtonShape.lineWidth = 4
        fireButtonShape.name = "fireButton"
        root.addChild(fireButtonShape)

        // Top highlight (lighter arc for bevel)
        let highlight = SKShapeNode(circleOfRadius: 38)
        highlight.fillColor = .clear
        highlight.strokeColor = SKColor(red: 1, green: 0.5, blue: 0.5, alpha: 0.3)
        highlight.lineWidth = 8
        highlight.name = "fireButton"
        root.addChild(highlight)

        // "B" label
        let bLbl = SKLabelNode(text: "B")
        bLbl.fontName = "Courier-Bold"; bLbl.fontSize = 26
        bLbl.fontColor = .white; bLbl.verticalAlignmentMode = .center
        bLbl.name = "fireButton"
        root.addChild(bLbl)
    }

    // MARK: - Weapon Selector

    private func buildWeaponSelector() {
        let cx = screenSize.width / 2 - 80
        let cy = -screenSize.height / 2 + 185

        // Weapon slot — dark bg, orange border (selected glow)
        weaponSlot = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
        weaponSlot.fillColor = SKColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 0.90)
        weaponSlot.strokeColor = Colors.playerOrange; weaponSlot.lineWidth = 3
        weaponSlot.position = CGPoint(x: cx, y: cy)
        addChild(weaponSlot)

        weaponLabel = SKLabelNode(text: "🍌")
        weaponLabel.fontSize = 24; weaponLabel.verticalAlignmentMode = .center
        weaponLabel.position = CGPoint(x: cx, y: cy)
        addChild(weaponLabel)

        // Prev button — styled
        let prev = buildArrowButton(text: "◀", color: SKColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 0.88))
        prev.position = CGPoint(x: cx - 36, y: cy)
        prev.name = "prevWeapon"
        addChild(prev)
        prevWeaponBtn = prev

        // Next button
        let next = buildArrowButton(text: "▶", color: SKColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 0.88))
        next.position = CGPoint(x: cx + 36, y: cy)
        next.name = "nextWeapon"
        addChild(next)
        nextWeaponBtn = next
    }

    private func buildArrowButton(text: String, color: SKColor) -> SKNode {
        let root = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: 28, height: 28))
        bg.fillColor = color; bg.strokeColor = Colors.playerOrange; bg.lineWidth = 2
        root.addChild(bg)

        let lbl = SKLabelNode(text: text)
        lbl.fontName = "Courier-Bold"; lbl.fontSize = 14
        lbl.fontColor = Colors.lineYellow; lbl.verticalAlignmentMode = .center
        root.addChild(lbl)

        return root
    }

    // MARK: - Update

    func update(lives: Int, cash: Int, timeElapsed: TimeInterval, missionName: String, weaponEmoji: String) {
        // Hearts
        for (i, h) in heartNodes.enumerated() {
            h.text = i < lives ? "❤️" : "🖤"
        }

        // Score — arcade format with zero-padding
        scoreLabel.text = String(format: "SCORE:%06d", cash)

        // Timer — "M:SS"
        let mins = Int(timeElapsed) / 60
        let secs = Int(timeElapsed) % 60
        timerLabel.text = String(format: "%d:%02d", mins, secs)

        missionLabel.text = missionName.uppercased()
        weaponLabel.text = weaponEmoji
    }

    // MARK: - Touch Handling

    func handleTouchBegan(_ touch: UITouch, in scene: SKScene) -> Bool {
        let loc = touch.location(in: self)
        let fireNodes = nodes(at: loc)

        if fireNodes.contains(where: { $0.name == "fireButton" }) {
            animateFireButton()
            delegate?.hudDidTapFire()
            return true
        }
        if fireNodes.contains(where: { $0.name == "prevWeapon" }) {
            animateButtonPress(node: prevWeaponBtn)
            delegate?.hudDidChangeWeapon(to: -1)
            return true
        }
        if fireNodes.contains(where: { $0.name == "nextWeapon" }) {
            animateButtonPress(node: nextWeaponBtn)
            delegate?.hudDidChangeWeapon(to: 1)
            return true
        }

        // Joystick
        let dist = distance(loc, joystickCenter)
        if dist < 80 {
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
        let dist = sqrt(dx * dx + dy * dy)
        let maxRadius: CGFloat = 45

        if dist <= maxRadius {
            joystickKnob.position = loc
        } else {
            let nx = dx / dist; let ny = dy / dist
            joystickKnob.position = CGPoint(x: joystickCenter.x + nx * maxRadius,
                                            y: joystickCenter.y + ny * maxRadius)
        }

        let normalized = CGVector(dx: dx / max(dist, 1) * min(dist / maxRadius, 1),
                                  dy: dy / max(dist, 1) * min(dist / maxRadius, 1))
        delegate?.hudJoystickMoved(normalized)
    }

    private func animateFireButton() {
        let pop = SKAction.sequence([
            SKAction.scale(to: 0.88, duration: 0.06),
            SKAction.scale(to: 1.0, duration: 0.06)
        ])
        fireButton.run(pop)
    }

    private func animateButtonPress(node: SKNode) {
        let tap = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.05)
        ])
        node.run(tap)
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x; let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }
}
