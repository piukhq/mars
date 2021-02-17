//
//  WebScrapable.swift
//  binkapp
//
//  Created by Nick Farrant on 03/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

enum WebScrapableMerchant: String {
    case tesco
    case boots
    case morrisons
    case superdrug
    case waterstones
    case heathrow
    case perfumeshop
}

protocol WebScrapable {
    var merchant: WebScrapableMerchant { get }
    var membershipPlanId: Int { get }
    var usernameField: FieldCommonName { get }
    var loyaltySchemeBalanceCurrency: String? { get }
    var loyaltySchemeBalanceSuffix: String? { get }
    var loyaltySchemeBalancePrefix: String? { get }
    var loginUrlString: String { get }
    var scrapableUrlString: String { get }
    var loginScriptFileName: String { get }
    var pointsScrapingScriptFileName: String { get }
}

extension WebScrapable {
    /// Some future merchants may use .username - override if that is the case.
    var usernameField: FieldCommonName {
        return .email
    }

    var loyaltySchemeBalanceCurrency: String? {
        return nil
    }

    var loyaltySchemeBalanceSuffix: String? {
        return nil
    }

    var loyaltySchemeBalancePrefix: String? {
        return nil
    }

    var loginScriptFileName: String {
        return "LocalPointsCollection_Login_\(merchant.rawValue.capitalized)"
    }

    var pointsScrapingScriptFileName: String {
        return "LocalPointsCollection_Points_\(merchant.rawValue.capitalized)"
    }
}
