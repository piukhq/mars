//
//  PaymentCardRequest.swift
//  binkapp
//
//  Created by Max Woodhams on 15/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentCardRequest: Codable {
    struct Card: Codable {
        let token: String
        let firstSixDigits: String
        let lastFourDigits: String
        let country: String
        let nameOnCard: String
        let month: Int
        let year: Int
        let fingerprint: String
    }
    
    struct Account: Codable {
        struct Consents: Codable {
            let latitude: Double
            let longitude: Double
            let timestamp: Double
            let type: Int
        }
        
        let consents: Consents
    }
    
    let card: Card
    let account: Account
}
