// ColmadoDashApp.swift — Colmado Dash
// SwiftUI app entry point — wraps the UIKit GameViewController

import SwiftUI

@main
struct ColmadoDashApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .ignoresSafeArea()
                .statusBarHidden(true)
        }
    }
}

struct GameView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        return GameViewController()
    }
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {}
}
