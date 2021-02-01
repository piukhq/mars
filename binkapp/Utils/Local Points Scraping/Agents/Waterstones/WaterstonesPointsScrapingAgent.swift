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

    var usernameFieldTitle: String {
        return "Email Address"
    }

    var passwordFieldTitle: String {
        return "Password"
    }

    var loyaltySchemeBalanceSuffix: String? {
        return "stamps"
    }

    var loginUrlString: String {
        return "https://www.waterstones.com/plus/signin"
    }

    var scrapableUrlString: String {
        return "https://www.waterstones.com/account/waterstonescard"
    }

    var incorrectCredentialsTextIdentiferClass: String? {
        return "plus-alert-info"
    }

    var incorrectCredentialsMessage: String? {
        return "Your login details are invalid. Please try again."
    }
}
