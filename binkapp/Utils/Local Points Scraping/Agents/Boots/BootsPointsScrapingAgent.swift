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
        return "https://www.boots.com/webapp/wcs/stores/servlet/BootsLogonForm"
    }
    
    var scrapableUrlString: String {
        return "https://www.boots.com/webapp/wcs/stores/servlet/AjaxLogonForm"
    }
    
    var reCaptchaMessage: String? {
        return "To login, confirm you are not a robot"
    }
    
    var reCaptchaTextIdentiferClass: String? {
        return "gigya-error-msg gigya-form-error-msg gigya-error-code-401020 gigya-error-msg-active"
    }
    
    var incorrectCredentialsMessage: String? {
        return "If you're seeing this message you've either made a mistake in typing in your password, or it's time to change it"
    }
    
    var incorrectCredentialsTextIdentiferClass: String? {
        return "gigya-error-msg gigya-form-error-msg gigya-error-msg-active gigya-error-code-403042"
    }
    
    var hasCaptcha: Bool {
        return false
    }
}
