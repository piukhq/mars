//
//  KFCPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 17/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

class KFCPointsScrapingAgent: WebScrapable {
    var merchant: WebScrapableMerchant {
        return .kfc
    }
    
    var membershipPlanId: Int {
        switch APIConstants.currentEnvironment {
        case .dev:
            return 66
        case .staging:
            return 66
        case .preprod:
            return 66
        case .production:
            return 66
        }
    }

    var loyaltySchemeBalanceSuffix: String? {
        return "stamps"
    }

    var scrapableUrlString: String {
        return "https://order.kfc.co.uk/account/my-rewards"
    }
}
