//
//  TescoPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 09/07/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct TescoScrapingAgent: WebScrapable {
    var merchant: WebScrapableMerchant {
        return .tesco
    }
    
    var membershipPlanId: Int {
        switch APIConstants.currentEnvironment {
        case .dev:
            return 207
        case .staging:
            return 230
        case .preprod:
            return 230
        case .production:
            return 203
        }
    }
    
    var usernameFieldTitle: String {
        return "Email"
    }
    
    var passwordFieldTitle: String {
        return "Password"
    }

    var loyaltySchemeBalanceCurrency: String? {
        return nil
    }

    var loyaltySchemeBalancePrefix: String? {
        return nil
    }

    var loyaltySchemeBalanceSuffix: String? {
        return "points"
    }
    
    var loginUrlString: String {
        return "https://secure.tesco.com/account/en-GB/login?from=https://secure.tesco.com/Clubcard/MyAccount/home/Home"
    }

    var scrapableUrlString: String {
        return "https://secure.tesco.com/Clubcard/MyAccount/home/Home"
    }

    var reCaptchaPresentationType: WebScrapingUtility.ReCaptchaPresentationType {
        return .none
    }
    
    var reCaptchaPresentationFrequency: WebScrapingUtility.ReCaptchaPresentationFrequency {
        return .never
    }
    
    var reCaptchaMessage: String? {
        return nil
    }
    
    var reCaptchaTextIdentiferClass: String? {
        return nil
    }
    
    var incorrectCredentialsMessage: String? {
        return nil
    }
    
    var incorrectCredentialsTextIdentiferClass: String? {
        return nil
    }
}
