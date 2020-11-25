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
    
    var usernameFieldTitle: String {
        return "Email address"
    }
    
    var passwordFieldTitle: String {
        return "Password"
    }
    
    var loyaltySchemeBalanceSuffix: String? {
        return "points"
    }
    
    var loginUrlString: String {
        return "https://my.morrisons.com/more/#/login"
    }
    
    var scrapableUrlString: String {
        return "https://my.morrisons.com/more/#/mypoints"
    }
    
    var reCaptchaPresentationType: WebScrapingUtility.ReCaptchaPresentationType {
        return .persistent
    }
    
    var reCaptchaPresentationFrequency: WebScrapingUtility.ReCaptchaPresentationFrequency {
        return .always
    }
}
