//
//  SocialLoginRequest.swift
//  binkapp
//
//  Created by Max Woodhams on 03/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct SignInWithAppleRequest: Codable {
    let authorizationCode: String
    
    enum CodingKeys: String, CodingKey {
        case authorizationCode = "authorization_code"
    }
}
