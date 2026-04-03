// GameState.swift — Colmado Dash
// Global game state, persistence, and enums

import Foundation
import Combine

enum VehicleType: String, Codable, CaseIterable {
    case bicycle = "bicycle"
    case moped   = "moped"
    case car     = "car"
    case concho  = "concho"

    var displayName: String {
        switch self {
        case .bicycle: return "Bicicleta"
        case .moped:   return "Moto"
        case .car:     return "Carro"
        case .concho:  return "Concho Taxi"
        }
    }

    var price: Int {
        switch self {
        case .bicycle: return 0
        case .moped:   return 500
        case .car:     return 2000
        case .concho:  return 4000
        }
    }

    var speed: CGFloat {
        switch self {
        case .bicycle: return 120
        case .moped:   return 200
        case .car:     return 280
        case .concho:  return 240
        }
    }

    var capacity: Int {
        switch self {
        case .bicycle: return 1
        case .moped:   return 2
        case .car:     return 3
        case .concho:  return 4
        }
    }

    var defense: Int {
        switch self {
        case .bicycle: return 1
        case .moped:   return 2
        case .car:     return 3
        case .concho:  return 4
        }
    }
}

enum WeaponType: String, Codable, CaseIterable {
    case platano = "platano"
    case huevo   = "huevo"
    case salami  = "salami"
    case fart    = "fart"

    var displayName: String {
        switch self {
        case .platano: return "🍌 Plátano"
        case .huevo:   return "🥚 Huevo"
        case .salami:  return "🥩 Salami"
        case .fart:    return "💨 Peo"
        }
    }

    var emoji: String {
        switch self {
        case .platano: return "🍌"
        case .huevo:   return "🥚"
        case .salami:  return "🥩"
        case .fart:    return "💨"
        }
    }
}

struct MissionData {
    let id: Int
    let pickupName: String
    let dropoffName: String
    let reward: Int
    let difficulty: String
    let hasSaboteurs: Bool
    let hasCops: Bool

    var description: String {
        "\(pickupName) → \(dropoffName)"
    }
}

class GameState: ObservableObject {
    static let shared = GameState()

    @Published var money: Int = 0
    @Published var vehicle: VehicleType = .bicycle
    @Published var weapons: [WeaponType] = [.platano]
    @Published var lives: Int = 3
    @Published var score: Int = 0
    @Published var highScore: Int = 0
    @Published var currentWeaponIndex: Int = 0
    @Published var ownedVehicles: Set<VehicleType> = [.bicycle]

    var currentWeapon: WeaponType { weapons[currentWeaponIndex] }

    let missions: [MissionData] = [
        MissionData(id: 0, pickupName: "Colmado La Palma", dropoffName: "Calle El Conde",  reward: 150, difficulty: "FÁCIL",  hasSaboteurs: false, hasCops: false),
        MissionData(id: 1, pickupName: "Colmado El Rey",   dropoffName: "Zona Colonial",   reward: 300, difficulty: "MEDIO",  hasSaboteurs: true,  hasCops: false),
        MissionData(id: 2, pickupName: "Ferretería La Fe", dropoffName: "Los Mina",         reward: 500, difficulty: "DIFÍCIL", hasSaboteurs: true,  hasCops: true),
        MissionData(id: 3, pickupName: "Colmado Don Cheo", dropoffName: "Villa Juana",      reward: 400, difficulty: "MEDIO",  hasSaboteurs: true,  hasCops: false),
        MissionData(id: 4, pickupName: "Banca Los Primos", dropoffName: "Naco",             reward: 600, difficulty: "DIFÍCIL", hasSaboteurs: true,  hasCops: true),
    ]

    private init() { load() }

    func nextWeapon() {
        currentWeaponIndex = (currentWeaponIndex + 1) % weapons.count
    }

    func prevWeapon() {
        currentWeaponIndex = (currentWeaponIndex - 1 + weapons.count) % weapons.count
    }

    func addWeapon(_ w: WeaponType) {
        if !weapons.contains(w) { weapons.append(w) }
    }

    func earnMoney(_ amount: Int) {
        money += amount
        score += amount
        if score > highScore { highScore = score; save() }
    }

    func spendMoney(_ amount: Int) -> Bool {
        guard money >= amount else { return false }
        money -= amount; save(); return true
    }

    func buyVehicle(_ v: VehicleType) -> Bool {
        guard spendMoney(v.price) else { return false }
        ownedVehicles.insert(v); vehicle = v; save(); return true
    }

    func reset() {
        lives = 3; score = 0; currentWeaponIndex = 0
    }

    func save() {
        let ud = UserDefaults.standard
        ud.set(money, forKey: "cd_money")
        ud.set(vehicle.rawValue, forKey: "cd_vehicle")
        ud.set(highScore, forKey: "cd_highscore")
        ud.set(weapons.map { $0.rawValue }, forKey: "cd_weapons")
        ud.set(ownedVehicles.map { $0.rawValue }, forKey: "cd_owned")
    }

    func load() {
        let ud = UserDefaults.standard
        money     = ud.integer(forKey: "cd_money")
        highScore = ud.integer(forKey: "cd_highscore")
        if let vs = ud.string(forKey: "cd_vehicle"), let v = VehicleType(rawValue: vs) { vehicle = v }
        if let ws = ud.array(forKey: "cd_weapons") as? [String] {
            weapons = ws.compactMap { WeaponType(rawValue: $0) }
            if weapons.isEmpty { weapons = [.platano] }
        }
        if let os = ud.array(forKey: "cd_owned") as? [String] {
            ownedVehicles = Set(os.compactMap { VehicleType(rawValue: $0) })
            ownedVehicles.insert(.bicycle)
        }
    }
}
