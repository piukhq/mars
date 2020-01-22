//
//  SpreedlyModels.swift
//  binkapp
//
//  Created by Nick Farrant on 22/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct SpreedlyRequest: Codable {
    struct PaymentMethod: Codable {
        struct CreditCard: Codable {
            let fullName: String?
            let number: String?
            let month: Int?
            let year: Int?

            enum CodingKeys: String, CodingKey {
                case fullName = "full_name"
                case number
                case month
                case year
            }
        }

        let creditCard: CreditCard?

        enum CodingKeys: String, CodingKey {
            case creditCard = "credit_card"
        }
    }

    let paymentMethod: PaymentMethod?

    init(fullName: String?, number: String?, month: Int?, year: Int?) {
        let creditCard = PaymentMethod.CreditCard(fullName: fullName, number: number, month: month, year: year)
        paymentMethod = PaymentMethod(creditCard: creditCard)
    }

    enum CodingKeys: String, CodingKey {
        case paymentMethod = "payment_method"
    }
}

struct SpreedlyResponse: Codable {
    var transaction: Transaction?

    struct Transaction: Codable {
        var paymentMethod: PaymentMethod?

        enum CodingKeys: String, CodingKey {
            case paymentMethod = "payment_method"
        }

        struct PaymentMethod: Codable {
            var token: String?
            var lastFour: String?
            var firstSix: String?
            var fingerprint: String?

            enum CodingKeys: String, CodingKey {
                case token
                case lastFour = "last_four_digits"
                case firstSix = "first_six_digits"
                case fingerprint
            }
        }
    }
}
