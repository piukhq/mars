//
//  LoginResponse.swift
//  binkapp
//
//  Created by Max Woodhams on 31/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import JWTDecode

struct LoginResponse: Codable {
    // Regular login, and renew token response
    var apiKey: String?
    
    // Regular login additional keys
    let userEmail: String?
    let uid: String?
    
    // Magic Link response
    let accessToken: String?
    
    
    // Abstrations
    
    // Abstract the two possible token response keys we can get
    var jwt: String? {
        return apiKey ?? accessToken
    }
    
    // Return the email if we have it, otherwise attempt to extract it from the token
    var email: String? {
        if let email = userEmail {
            return email
        }
        
        guard let jwt = jwt else { return nil }
        let decodedToken = try? decode(jwt: jwt)
        return decodedToken?.body["user_id"] as? String
    }
    
    enum CodingKeys: String, CodingKey {
        case userEmail = "email"
        case uid
        case apiKey = "api_key"
        case accessToken = "access_token"
    }
}
