//
//  AutofillUtility.swift
//  binkapp
//
//  Created by Sean Williams on 26/11/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation
import KeychainAccess

enum Autofill {
    static let keychain = Keychain(service: APIConstants.bundleID)
    static let keychainKey = "autofill_values"
    static let slug = "remember-my-details"
    static let email = "email"
    static let categories = ["first name", "last name", "email", "phone", "date of birth"]
    
    static func storedDataFromKeychain() -> [String: [String]]? {
        if let autofillDataFromKeychain = try? keychain.getData(Autofill.keychainKey) {
            if let decodedAutofillValues = try? JSONDecoder().decode([String: [String]].self, from: autofillDataFromKeychain) {
                return decodedAutofillValues
            }
        }
        return nil
    }
    
    static func save(_ autofillDict: [String: [String]]) {
        if let autofillData = try? JSONEncoder().encode(autofillDict) {
            try? keychain.set(autofillData, key: Autofill.keychainKey)
        }
    }
    
    static func clearKeychain() throws {
        try keychain.remove(keychainKey)
    }
}
