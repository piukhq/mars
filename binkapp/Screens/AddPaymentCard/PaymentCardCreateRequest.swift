//
//  PaymentCardCreateRequest.swift
//  binkapp
//
//  Created by Max Woodhams on 18/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CryptoSwift

struct PaymentCardCreateRequest: Codable {
    struct Card: Codable {
        enum CodingKeys: String, CodingKey {
            case token
            case firstSixDigits = "first_six_digits"
            case lastFourDigits = "last_four_digits"
            case country
            case nameOnCard = "name_on_card"
            case month
            case year
            case fingerprint
        }
        
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
            let timestamp: Int
            let type: Int
        }

        // These are default consents by design from architecture
        var consents: [Consents]?
    }
    
    let card: Card

    let account: Account
    
    /// This should only be used for creating test payment cards as it naturally bypasses the Spreedly path
    init?(model: PaymentCardCreateModel, spreedlyResponse: SpreedlyResponse? = nil) {
        guard let pan = model.fullPan?.replacingOccurrences(of: " ", with: ""),
            let year = model.year,
            let month = model.month
            else { return nil }
        
        // Get first six and last four
        
        var firstSix: String? = nil
        var lastFour: String? = nil
        if let firstSixEndIndex = pan.index(pan.startIndex, offsetBy: 6, limitedBy: pan.endIndex),
            let lastFourStartIndex = pan.index(pan.endIndex, offsetBy: -4, limitedBy: pan.startIndex) {
            firstSix = String(pan[pan.startIndex..<firstSixEndIndex])
            lastFour = String(pan[lastFourStartIndex..<pan.endIndex])
        }

        // TODO: Handle optionals?
        card = Card(
            token: spreedlyResponse == nil ? PaymentCardCreateRequest.fakeToken() : spreedlyResponse?.transaction?.paymentMethod?.token ?? "",
            firstSixDigits: spreedlyResponse == nil ? firstSix! : spreedlyResponse?.transaction?.paymentMethod?.firstSix ?? "",
            lastFourDigits: spreedlyResponse == nil ? lastFour! : spreedlyResponse?.transaction?.paymentMethod?.lastFour ?? "",
            country: "GB", //TODO: Needs resolving!
            nameOnCard: model.nameOnCard!,
            month: month,
            year: year,
            fingerprint: spreedlyResponse == nil ? PaymentCardCreateRequest.fakeFingerprint(pan: pan, expiryYear: String(year), expiryMonth: String(month)) : spreedlyResponse?.transaction?.paymentMethod?.fingerprint ?? ""
        )

        let timestamp = Date().timeIntervalSince1970
        account = Account(consents: [Account.Consents(latitude: 0.0, longitude: 0.0, timestamp: Int(timestamp), type: 0)])
    }
    
    private static func fakeFingerprint(pan: String, expiryYear: String, expiryMonth: String) -> String {
        // Based a hash of the pan, it's the key identifier of the card
        return "\(pan)|\(expiryMonth)|\(expiryYear)".md5()
    }
    
    private static func fakeToken() -> String {
        // A random string per request
        return String.randomString(length: 100)
    }
}
