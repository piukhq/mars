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
    case starbucks
    case subway
}

protocol WebScrapable {
    var merchant: WebScrapableMerchant { get }
    var membershipPlanId: Int { get }
    var usernameField: FieldCommonName { get }
    var requiredCredentials: [PointsScrapingManager.CredentialStoreType] { get }
    var loyaltySchemeBalanceCurrency: String? { get }
    var loyaltySchemeBalanceSuffix: String? { get }
    var loyaltySchemeBalancePrefix: String? { get }
    var scrapableUrlString: String { get }
    var navigateScriptFileName: String { get }
}

extension WebScrapable {
    /// Some  merchants may use .username - override if that is the case.
    var usernameField: FieldCommonName {
        return .email
    }
    
    var requiredCredentials: [PointsScrapingManager.CredentialStoreType] {
        return [.username, .password]
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
    
    var navigateScriptFileName: String {
        return "LocalPointsCollection_Navigate_\(merchant.rawValue.capitalized)"
    }
}
