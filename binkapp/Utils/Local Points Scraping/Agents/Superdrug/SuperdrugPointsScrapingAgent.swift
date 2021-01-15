//
//  SuperdrugPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 16/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct SuperdrugScrapingAgent: WebScrapable {
    var merchant: WebScrapableMerchant {
        return .superdrug
    }

    var membershipPlanId: Int {
        switch APIConstants.currentEnvironment {
        case .dev:
            return 16
        case .staging:
            return 16
        case .preprod:
            return 16
        case .production:
            return 16
        }
    }

    var usernameFieldTitle: String {
        return "Email Address"
    }

    var passwordFieldTitle: String {
        return "Password"
    }

    var loyaltySchemeBalanceSuffix: String? {
        return "points"
    }

    var loginUrlString: String {
        return "https://www.superdrug.com/login"
    }

    var scrapableUrlString: String {
        return "https://www.superdrug.com/login"
    }
}
