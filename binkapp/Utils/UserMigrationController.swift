//
//  UserMigrationController.swift
//  binkapp
//
//  Created by Max Woodhams on 03/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import JWTDecode

struct UserMigrationController {
    
    private struct Constants {
        static let hasMigratedFromBinkLegacyKey = "hasMigratedFromBinkLegacyKey"
        static let internalDictKey = "BINKKeychainInternalDictionary"
        static let userClass = "BINKUser"
        static let authTokenClass = "BINKAuthToken"
        static let currentUserKey = "BINKCurrentUserKey"
    }
    
    private var legacyToken: String? = nil
    
    init() {
        legacyToken = retrieveBinkLegacyToken()
    }
    
    var shouldMigrate: Bool {
        return hasMigrated == false && legacyToken != nil
    }
    
    private var hasMigrated: Bool {
        return Current.userDefaults.bool(forKey: Constants.hasMigratedFromBinkLegacyKey)
    }
    
    func renewTokenFromLegacyAppIfPossible(completion: @escaping (Bool) -> ()) {
        guard hasMigrated == false, let token = legacyToken else {
            completion(false)
            return
        }

        // TODO: Request should become a static let in a service in future ticket
        let request = BinkNetworkRequest(endpoint: .renew, method: .post, headers: ["Authorization" : "Token " + token, "Content-Type" : "application/json", "Accept": "application/json;\(Current.apiClient.apiVersion.rawValue)"], isUserDriven: false)
        Current.apiClient.performRequest(request, expecting: RenewTokenResponse.self) { result in
            switch result {
            case .success(let response):
                var email: String?
                do {
                    let jwt = try decode(jwt: token)
                    email = jwt.body["user_id"] as? String
                } catch {
                    completion(false)
                }

                guard let renewEmail = email else {
                    completion(false)
                    return
                }

                Current.userManager.setNewUser(with: response)

                let request = BinkNetworkRequest(endpoint: .service, method: .post, headers: nil, isUserDriven: false)
                Current.apiClient.performRequestWithNoResponse(request, parameters: APIConstants.makeServicePostRequest(email: renewEmail)) { (success, error) in
                    guard success else {
                        Current.userManager.removeUser()
                        completion(false)
                        return
                    }
                    Current.userDefaults.set(true, forKey: Constants.hasMigratedFromBinkLegacyKey)
                    completion(true)
                }
            case .failure:
                Current.userManager.removeUser()
                completion(false)
            }
        }
    }
    
    private func retrieveBinkLegacyToken() -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecAttrAccount as String: Constants.internalDictKey,
                                    kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else { return nil }
        
        guard let existingItem = item as? [String : Any], let data = existingItem[kSecValueData as String] as? Data else {
            return nil
        }
        
        NSKeyedUnarchiver.setClass(User.self, forClassName: Constants.userClass)
        NSKeyedUnarchiver.setClass(AuthToken.self, forClassName: Constants.authTokenClass)
        
        if let dict = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String : AnyObject],
            let user = dict[Constants.currentUserKey] as? User {
            // If we were successful in mapping to our new class types
            return user.token.accessToken
        }
        
        return nil
    }
}


@objc class User: NSObject, NSSecureCoding {
    static var supportsSecureCoding = true
    
    func encode(with coder: NSCoder) {
        coder.encode(token, forKey: "token")
    }
    
    required init?(coder: NSCoder) {
        guard let token = coder.decodeObject(forKey: "token") as? AuthToken else {
            fatalError()
        }
        
        self.token = token
    }
    
    let token: AuthToken
}

@objc class AuthToken: NSObject, NSSecureCoding {
    func encode(with coder: NSCoder) {
        coder.encode(accessToken, forKey: "accessToken")
    }
    
    required init?(coder: NSCoder) {
        guard let accessToken = coder.decodeObject(forKey: "accessToken") as? String else {
            fatalError()
        }
        self.accessToken = accessToken
    }
    
    static var supportsSecureCoding = true

    let accessToken: String
}
