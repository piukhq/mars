//
//  PerfumeShopPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 17/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct PerfumeShopScrapingAgent: WebScrapable {
    var merchant: WebScrapableMerchant {
        return .perfumeshop
    }

    var membershipPlanId: Int {
        switch APIConstants.currentEnvironment {
        case .dev:
            return 78
        case .staging:
            return 78
        case .preprod:
            return 78
        case .production:
            return 78
        }
    }

    var usernameFieldTitle: String {
        return "email"
    }

    var passwordFieldTitle: String {
        return "password"
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
        return "https://www.theperfumeshop.com/login"
    }

    var scrapableUrlString: String {
        return "https://www.theperfumeshop.com/my-account"
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
