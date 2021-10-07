//
//  SubwayPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 22/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

class SubwayPointsScrapingAgent: WebScrapable {
    var merchant: WebScrapableMerchant {
        return .subway
    }
    
    var membershipPlanId: Int {
        switch APIConstants.currentEnvironment {
        case .dev:
            return 65
        case .staging:
            return 65
        case .preprod:
            return 65
        case .production:
            return 65
        }
    }

    var loyaltySchemeBalanceSuffix: String? {
        return "points"
    }

    var scrapableUrlString: String {
        return "https://subcard.subway.co.uk/cardholder/en/"
    }
}
