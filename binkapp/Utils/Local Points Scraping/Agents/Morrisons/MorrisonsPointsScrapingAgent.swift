//
//  MorrisonsPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 10/09/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct MorrisonsScrapingAgent: WebScrapable {
    var merchant: WebScrapableMerchant {
        return .morrisons
    }
    
    var membershipPlanId: Int {
        switch APIConstants.currentEnvironment {
        case .dev:
            return 12
        case .staging:
            return 12
        case .preprod:
            return 12
        case .production:
            return 12
        }
    }
    
    var loyaltySchemeBalanceSuffix: String? {
        return "points"
    }
    
    var scrapableUrlString: String {
        return "https://my.morrisons.com/more/#/mypoints"
    }
}
