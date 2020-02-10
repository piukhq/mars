//
//  LoginResponse.swift
//  binkapp
//
//  Created by Max Woodhams on 31/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

protocol TokenResponseProtocol {
    var apiKey: String? { get }
}

struct LoginRegisterResponse: Codable, TokenResponseProtocol {
    var apiKey: String?
    let email: String?
    let uid: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case uid
        case apiKey = "api_key"
    }
}
