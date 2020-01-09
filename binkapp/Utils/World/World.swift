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
}

protocol BinkUserDefaults {
    // BinkUserDefaults specific methods supporting Keys
    func set(_ value: Any?, forKey defaultName: UserDefaults.Keys)
    func string(forKey defaultName: UserDefaults.Keys) -> String?
    func bool(forKey defaultName: UserDefaults.Keys) -> Bool

    // UserDefault methods where we cannot support Keys
    func set(_ value: Any?, forKey defaultName: String)
    func string(forKey defaultName: String) -> String?
    func bool(forKey defaultName: String) -> Bool
}

extension UserDefaults: BinkUserDefaults {
    enum Keys: String {
        case hasFetchedDataOnLaunch
        case userEmail
    }

    func set(_ value: Any?, forKey defaultName: UserDefaults.Keys) {
        set(value, forKey: defaultName.rawValue)
    }

    func string(forKey defaultName: UserDefaults.Keys) -> String? {
        return string(forKey: defaultName.rawValue)
    }

    func bool(forKey defaultName: UserDefaults.Keys) -> Bool {
        return bool(forKey: defaultName.rawValue)
    }
}
