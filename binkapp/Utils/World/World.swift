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
}

protocol BinkUserDefaults {
    func set(_ value: Any?, forKey defaultName: String)
    func string(forKey defaultName: String) -> String?
    func bool(forKey defaultName: String) -> Bool
}

extension UserDefaults: BinkUserDefaults {}
