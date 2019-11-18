//
//  LoginRequest.swift
//  binkapp
//
//  Created by Max Woodhams on 31/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct LoginRegisterRequest: Codable {
    let email: String?
    let password: String?
    let clientID: String
    let bundleID: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
        case clientID = "client_id"
        case bundleID = "bundle_id"
    }
    
    init(email: String?, password: String?) {
        self.email = email
        self.password = password
        self.clientID = APIConstants.clientID
        self.bundleID = APIConstants.bundleID
    }
}
