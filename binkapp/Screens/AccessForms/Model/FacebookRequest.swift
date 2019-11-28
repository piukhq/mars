//
//  FacebookRequest.swift
//  binkapp
//
//  Created by Max Woodhams on 03/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct FacebookRequest: Codable {
    let accessToken: String
    var email: String?
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case email
        case userId = "user_id"
    }
}
