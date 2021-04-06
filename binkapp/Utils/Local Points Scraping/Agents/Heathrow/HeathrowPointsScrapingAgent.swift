//
//  HeathrowPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 17/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct HeathrowScrapingAgent: WebScrapable {
    var merchant: WebScrapableMerchant {
        return .heathrow
    }

    var membershipPlanId: Int {
        switch APIConstants.currentEnvironment {
        case .dev:
            return 32
        case .staging:
            return 32
        case .preprod:
            return 32
        case .production:
            return 32
        }
    }

    var usernameField: FieldCommonName {
        return .username
    }

    var loyaltySchemeBalanceSuffix: String? {
        return "points"
    }

//    var loginUrlString: String {
//        return "https://www.heathrow.com/heathrow-rewards/login"
//    }

    var scrapableUrlString: String {
        return "https://www.heathrow.com/rewards/home"
    }
}
