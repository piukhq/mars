//
//  LogoutResponse.swift
//  binkapp
//
//  Created by Max Woodhams on 01/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct LogoutResponse: Codable {
    let loggedOut: Bool
    
    enum CodingKeys: String, CodingKey {
        case loggedOut = "logged_out"
    }
}
