//
//  BootsPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 08/09/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct BootsScrapingAgent: WebScrapable {
    var merchant: WebScrapableMerchant {
        return .boots
    }
    
    var membershipPlanId: Int {
        switch APIConstants.currentEnvironment {
        case .dev:
            return 4
        case .staging:
            return 4
        case .preprod:
            return 4
        case .production:
            return 4
        }
    }
    
    var loyaltySchemeBalanceSuffix: String? {
        return "points"
    }
    
    var loginUrlString: String {
        return "https://www.boots.com/webapp/wcs/stores/servlet/BootsLogonForm"
    }
    
    var scrapableUrlString: String {
        return "https://www.boots.com/webapp/wcs/stores/servlet/AjaxLogonForm"
    }
}
