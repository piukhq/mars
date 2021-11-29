//
//  AutofillUtil.swift
//  binkapp
//
//  Created by Sean Williams on 26/11/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation
import KeychainAccess

class AutofillUtil: UserServiceProtocol {
    static let keychain = Keychain(service: APIConstants.bundleID)
    static let keychainKey = "autofill_values"
    static let slug = "remember-my-details"
    static let email = "email"
    static let categories = ["first name", "last name", "email", "phone", "date of birth"]
    
    static func storedDataFromKeychain() -> [String: [String]]? {
        if let autofillDataFromKeychain = try? keychain.getData(keychainKey) {
            if let decodedAutofillValues = try? JSONDecoder().decode([String: [String]].self, from: autofillDataFromKeychain) {
                return decodedAutofillValues
            }
        }
        return nil
    }
    
    static func save(_ autofillDict: [String: [String]]) {
        if let autofillData = try? JSONEncoder().encode(autofillDict) {
            try? keychain.set(autofillData, key: keychainKey)
        }
    }
    
    static func clearKeychain() throws {
        try keychain.remove(keychainKey)
    }
    
    func configureUserPreferenceFromAPI() {
        getPreferences { result in
            switch result {
            case .success(let preferences):
                let value = preferences.first(where: { $0.slug == AutofillUtil.slug })?.value
                let checked: Bool = value == "1"
                Current.userDefaults.set(checked, forDefaultsKey: .rememberMyDetails)
            case .failure:
                break
            }
        }
    }
}
