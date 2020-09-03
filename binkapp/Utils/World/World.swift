//
//  World.swift
//  binkapp
//
//  Created by Nick Farrant on 19/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

let Current = World()

class World {
    lazy var database = Database(named: "binkapp")
    lazy var wallet = Wallet()
    lazy var userDefaults: BinkUserDefaults = UserDefaults.standard
    lazy var userManager = UserManager()
    lazy var apiClient = APIClient()
    lazy var navigate = Navigate()
    lazy var pointsScrapingManager = PointsScrapingManager()
    lazy var remoteConfig = RemoteConfigUtil()
    var onboardingTrackingId: String? // Stored to provide a consistent id from start to finish of onboarding, reset upon a new journey
}

protocol BinkUserDefaults {
    // BinkUserDefaults specific methods supporting Keys
    func set(_ value: Any?, forDefaultsKey defaultName: UserDefaults.Keys)
    func string(forDefaultsKey defaultName: UserDefaults.Keys) -> String?
    func bool(forDefaultsKey defaultName: UserDefaults.Keys) -> Bool
    func value(forDefaultsKey defaultName: UserDefaults.Keys) -> Any?

    // UserDefault methods where we cannot support Keys
    func set(_ value: Any?, forKey defaultName: String)
    func string(forKey defaultName: String) -> String?
    func bool(forKey defaultName: String) -> Bool
    func value(forKey defaultName: String) -> Any?
}

extension UserDefaults: BinkUserDefaults {

    enum Keys {
        case hasLaunchedWallet
        case userEmail
        case debugBaseURL
        case webScrapingCookies(membershipCardId: String)
        
        var keyValue: String {
            switch self {
            case .hasLaunchedWallet:
                return "hasLaunchedWallet"
            case .userEmail:
                return "userEmail"
            case .debugBaseURL:
                return "debugBaseURL"
            case .webScrapingCookies(let membershipCardId):
                return "webScrapingCookies_cardId_\(membershipCardId)"
            }
        }
    }

    func set(_ value: Any?, forDefaultsKey defaultName: UserDefaults.Keys) {
        set(value, forKey: defaultName.keyValue)
    }

    func string(forDefaultsKey defaultName: UserDefaults.Keys) -> String? {
        return string(forKey: defaultName.keyValue)
    }

    func bool(forDefaultsKey defaultName: UserDefaults.Keys) -> Bool {
        return bool(forKey: defaultName.keyValue)
    }

    func value(forDefaultsKey defaultName: UserDefaults.Keys) -> Any? {
        return value(forKey: defaultName.keyValue)
    }
}
