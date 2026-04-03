// SoundManager.swift — Colmado Dash
// Handles sound effects with AVAudioPlayer (no external files needed — uses system sounds via haptics)
// All audio calls are safe no-ops if files don't exist.

import Foundation
import AVFoundation
import UIKit

class SoundManager {
    static let shared = SoundManager()

    private var players: [String: AVAudioPlayer] = [:]
    private var isMuted = false

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: - Haptic feedback (works without audio files)

    func playPickup() {
        haptic(.medium)
    }

    func playDeliver() {
        haptic(.heavy)
        // Double tap feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.haptic(.heavy)
        }
    }

    func playThrow() {
        haptic(.light)
    }

    func playHit() {
        haptic(.medium)
    }

    func playPowerup() {
        haptic(.heavy)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.haptic(.medium) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.haptic(.light) }
    }

    func playCrash() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.error)
    }

    func playPurchase() {
        haptic(.medium)
    }

    func playMenuTap() {
        haptic(.light)
    }

    func toggleMute() { isMuted.toggle() }

    private func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard !isMuted else { return }
        let gen = UIImpactFeedbackGenerator(style: style)
        gen.impactOccurred()
    }
}
