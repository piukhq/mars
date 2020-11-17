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

    var usernameFieldTitle: String {
        return "email/card number"
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
        return "https://www.heathrow.com/heathrow-rewards/login"
    }

    var scrapableUrlString: String {
        return "https://www.heathrow.com/rewards/home?login=Login%20Succcessful"
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
