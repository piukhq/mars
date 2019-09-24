//
//  PaymentCardResponse.swift
//  binkapp
//
//  Created by Max Woodhams on 19/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentCardResponse: Codable {
    struct Card: Codable {
        enum Provider: String, Codable {
            case Visa
            case Amex
            case Mastercard
        }
        
        let firstSixDigits: String?
        let lastFourDigits: String?
        let month: Int?
        let year: Int?
        let currencyCode: String?
        let nameOnCard: String?
        let provider: Provider?
        let type: String?
        
        enum CodingKeys: String, CodingKey {
            case firstSixDigits = "first_six_digits"
            case lastFourDigits = "last_four_digits"
            case month
            case year
            case currencyCode = "currency_code"
            case nameOnCard = "name_on_card"
            case provider
            case type
        }
    }
    
    
    let id: Int
    let status: String?
    let card: Card?
    let membershipCards: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case card
        case membershipCards = "membership_cards"
    }
}


//"{\"id\":13898,\"membership_cards\":[],\"status\":\"pending\",\"card\":{\"first_six_digits\":\"424242\",\"last_four_digits\":\"4242\",\"month\":12,\"year\":2029,\"country\":\"GB\",\"currency_code\":\"GBP\",\"name_on_card\":\"M Woodhams\",\"provider\":\"Visa\",\"type\":\"debit\"},\"images\":[{\"id\":7,\"type\":0,\"url\":\"https://api.bink-dev.com/content/dev-media/hermes/schemes/Visa-Payment_DWQzhta.png\",\"description\":\"Visa Card Image\",\"encoding\":\"png\"}],\"account\":{\"verification_in_progress\":false,\"status\":1,\"consents\":[]}}"


//{
//    "id": 5031,
//    "membership_cards": [],
//    "status": "active",
//    "card": {
//        "first_six_digits": "424242",
//        "last_four_digits": "4242",
//        "month": 5,
//        "year": 2020,
//        "country": "UK",
//        "currency_code": "GBP",
//        "name_on_card": "B Vas",
//        "provider": "Visa",
//        "type": "debit"
//    },
//    "images": [],
//    "account": {
//        "verification_in_progress": false,
//        "status": 1,
//        "consents": [
//        {
//        "latitude": 51.405372,
//        "longitude": -0.678357,
//        "timestamp": 1544525833,
//        "type": 0
//        }
//        ]
//    }
//}
