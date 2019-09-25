//
//  PaymentCardModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 10/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct PaymentCardModel: Codable {
    var id: Int?
    var membershipCards: [PaymentCardMembershipCardResponse]?
    var status: String?
    var card: PaymentCardCardResponse?
    var images: [MembershipCardImageModel]?
    var account: PaymentCardAccountResponse?

    enum CodingKeys: String, CodingKey {
        case id
        case membershipCards = "membership_cards"
        case status
        case card
        case images
        case account
    }

    struct PaymentCardMembershipCardResponse: Codable {
        var id: Int?
        var activeLink: Bool

        enum CodingKeys: String, CodingKey {
            case id
            case activeLink = "active_link"
        }
    }

    struct PaymentCardAccountResponse: Codable {
        var verificationInProgress: Bool?
        var status: Int?
        var consents: [PaymentCardAccountConsentsResponse]?

        enum CodingKeys: String, CodingKey {
            case verificationInProgress = "verification_in_progress"
            case status
            case consents
        }
    }

    struct PaymentCardAccountConsentsResponse: Codable {
        var type: Int?
        var timestamp: Int?
    }

    struct PaymentCardCardResponse: Codable {
        var firstSix: String? 
        var lastFour: String?
        var month: Int?
        var year: Int?
        var country: String?
        var currencyCode: String?
        var nameOnCard: String?
        var provider: PaymentCardType?
        var type: String?

        enum CodingKeys: String, CodingKey {
            case firstSix = "first_six_digits"
            case lastFour = "last_four_digits"
            case month
            case year
            case country
            case currencyCode = "currency_code"
            case nameOnCard = "name_on_card"
            case provider
            case type
        }
    }
}
