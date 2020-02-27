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
            case hash1
        }
        
        let token: String
        let firstSixDigits: String
        let lastFourDigits: String
        let country: String
        let nameOnCard: String
        let month: Int
        let year: Int
        let fingerprint: String
        let hash1: String
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
    init?(model: PaymentCardCreateModel, hash: String) {
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

        card = Card(
            token: PaymentCardCreateRequest.fakeToken(),
            firstSixDigits: firstSix!, // TODO: encrypt this
            lastFourDigits: lastFour!, // TODO: encrypt this
            country: "GB", //TODO: Needs resolving!
            nameOnCard: model.nameOnCard!,
            month: month, // TODO: encrypt this
            year: year, // TODO: encrypt this
            fingerprint: PaymentCardCreateRequest.fakeFingerprint(pan: pan, expiryYear: String(year), expiryMonth: String(month)),
            hash1: hash // TODO: encrypt this
        )

        let timestamp = Date().timeIntervalSince1970
        account = Account(consents: [Account.Consents(latitude: 0.0, longitude: 0.0, timestamp: Int(timestamp), type: 0)])
    }

    /// This should only be used for creating genuine payment cards using Spreedly path in a production environment
    init?(spreedlyResponse: SpreedlyResponse, hash: String) {
        card = Card(
            token: spreedlyResponse.transaction?.paymentMethod?.token ?? "",
            firstSixDigits: spreedlyResponse.transaction?.paymentMethod?.firstSix ?? "", // TODO: encrypt this
            lastFourDigits: spreedlyResponse.transaction?.paymentMethod?.lastFour ?? "", // TODO: encrypt this
            country: "GB", //TODO: Needs resolving!
            nameOnCard: spreedlyResponse.transaction?.paymentMethod?.fullName ?? "",
            month: spreedlyResponse.transaction?.paymentMethod?.month ?? 0, // TODO: encrypt this
            year: spreedlyResponse.transaction?.paymentMethod?.year ?? 0, // TODO: encrypt this
            fingerprint: spreedlyResponse.transaction?.paymentMethod?.fingerprint ?? "",
            hash1: hash // TODO: encrypt this
        )

        let timestamp = Date().timeIntervalSince1970
        account = Account(consents: [Account.Consents(latitude: 0.0, longitude: 0.0, timestamp: Int(timestamp), type: 0)])
    }
    
    private static func fakeFingerprint(pan: String, expiryYear: String, expiryMonth: String) -> String {
        // Based a hash of the pan, it's the key identifier of the card
        return "\(pan)|\(expiryMonth)|\(expiryYear)".md5() // Maybe we should do something similar to this for pan hashing?
    }
    
    private static func fakeToken() -> String {
        // A random string per request
        return String.randomString(length: 100)
    }
}
