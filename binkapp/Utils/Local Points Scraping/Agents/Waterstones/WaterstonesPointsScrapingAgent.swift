//
//  WaterstonesPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 17/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct WaterstonesScrapingAgent: WebScrapable {
    var merchant: WebScrapableMerchant {
        return .waterstones
    }

    var membershipPlanId: Int {
        switch APIConstants.currentEnvironment {
        case .dev:
            return 52
        case .staging:
            return 52
        case .preprod:
            return 52
        case .production:
            return 52
        }
    }

    var loyaltySchemeBalanceSuffix: String? {
        return "stamps"
    }

    var scrapableUrlString: String {
        return "https://www.waterstones.com/account/waterstonescard"
    }
}
