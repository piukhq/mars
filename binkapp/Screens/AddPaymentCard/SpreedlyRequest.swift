//
//  SpreedlyRequest.swift
//  binkapp
//
//  Created by Max Woodhams on 15/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct SpreedlyRequest: Codable {
    struct PaymentMethod: Codable {
        struct CreditCard: Codable {
            let firstName: String
            let lastName: String
            let number: String
            let month: String
            let year: String
            
            enum CodingKeys: String, CodingKey {
                case firstName = "first_name"
                case lastName = "last_name"
                case number
                case month
                case year
            }
        }
        
        let creditCard: CreditCard
        
        enum CodingKeys: String, CodingKey {
            case creditCard = "credit_card"
        }
    }
    
    let paymentMethod: PaymentMethod
    
    init(firstName: String, lastName: String, number: String, month: String, year: String) {
        let creditCard = PaymentMethod.CreditCard(firstName: firstName, lastName: lastName, number: number, month: month, year: year)
        paymentMethod = PaymentMethod(creditCard: creditCard)
    }
    
    enum CodingKeys: String, CodingKey {
        case paymentMethod = "payment_method"
    }
}
