//
//  StarbucksPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 30/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

class StarbucksPointsScrapingAgent: WebScrapable {
    var merchant: WebScrapableMerchant {
        return .starbucks
    }
    
    var membershipPlanId: Int {
        switch APIConstants.currentEnvironment {
        case .dev:
            return 15
        case .staging:
            return 15
        case .preprod:
            return 15
        case .production:
            return 15
        }
    }

    var loyaltySchemeBalanceSuffix: String? {
        return "points"
    }

    var scrapableUrlString: String {
        return "https://www.starbucks.co.uk/account/rewards/my-rewards"
    }
}
