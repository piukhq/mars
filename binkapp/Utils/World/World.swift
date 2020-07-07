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

    enum Keys: String {
        case hasLaunchedWallet
        case userEmail
        case debugBaseURL
        case httpCookies
    }

    func set(_ value: Any?, forDefaultsKey defaultName: UserDefaults.Keys) {
        set(value, forKey: defaultName.rawValue)
    }

    func string(forDefaultsKey defaultName: UserDefaults.Keys) -> String? {
        return string(forKey: defaultName.rawValue)
    }

    func bool(forDefaultsKey defaultName: UserDefaults.Keys) -> Bool {
        return bool(forKey: defaultName.rawValue)
    }

    func value(forDefaultsKey defaultName: UserDefaults.Keys) -> Any? {
        return value(forKey: defaultName.rawValue)
    }
}
