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
        return "Email Address / Card Number"
    }

    var passwordFieldTitle: String {
        return "Password"
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

    var incorrectCredentialsTextIdentiferClass: String? {
        return "flex flex-center validation-error-message login-error-message lg-px6 md-px2 sm-px1"
    }

    var incorrectCredentialsMessage: String? {
        return "Invalid Login Details. Please check the details you have entered and try again"
    }

    var loginScriptFileName: String {
        return "LocalPointsCollection_Login_Heathrow"
    }
}
