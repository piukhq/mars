//
//  TescoPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 09/07/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct TescoScrapingAgent: WebScrapable {
    var membershipPlanId: Int {
        switch APIConstants.currentEnvironment {
        case .dev:
            return 207
        case .staging:
            return 207
        case .preprod:
            return 207
        case .production:
            return 207
        }
    }

    var loyaltySchemeBalanceCurrency: String? {
        return nil
    }

    var loyaltySchemeBalancePrefix: String? {
        return nil
    }

    var loyaltySchemeBalanceSuffix: String? {
        return "pts"
    }
    
    var loginUrlString: String {
        return "https://secure.tesco.com/account/en-GB/login?from=https://secure.tesco.com/Clubcard/MyAccount/home/Home"
    }

    var scrapableUrlString: String {
        return "https://secure.tesco.com/Clubcard/MyAccount/home/Home"
    }

    var loginScriptFileName: String {
        return "TescoLogin"
    }

    var pointsScrapingScriptFileName: String {
        return "TescoPointsScrape"
    }
}
