// GameViewController.swift — Colmado Dash
// UIViewController hosting the SpriteKit view

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = view as? SKView else {
            fatalError("Root view is not SKView")
        }

        // Debug (disable for release)
        skView.showsFPS        = false
        skView.showsNodeCount  = false
        skView.showsPhysics    = false
        skView.ignoresSiblingOrder = true

        let scene = MenuScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }

    override func loadView() {
        self.view = SKView(frame: UIScreen.main.bounds)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
