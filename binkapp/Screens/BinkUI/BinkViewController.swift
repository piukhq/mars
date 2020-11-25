//
//  BinkViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 25/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import FirebaseAnalytics

enum TrackedScreen: String {
    case onboarding = "Onboarding"
    case login = "Login"
    case register = "Register"
    case socialTermsAndConditions = "SocialTermsAndConditions"
    case loyaltyWallet = "LoyaltyWallet"
    case paymentWallet = "PaymentWallet"
    case loyaltyDetail = "LoyaltyDetail"
    case paymentDetail = "PaymentDetail"
    case addOptions = "AddOptions"
    case browseBrands = "BrowseBrands"
    case storeViewLink = "StoreViewLink"
    case addPaymentCard = "AddPaymentCard"
    case addAuthForm = "AddAuthForm"
    case enrolForm = "EnrolForm"
    case registrationForm = "RegistrationForm"
    case pll = "PLL"
    case informationModal = "InformationModal"
    case settings = "Settings"
    case preferences = "Preferences"
}

class BinkViewController: UIViewController {
    var screenName: String?
    func setScreenName(trackedScreen: TrackedScreen) {
        screenName = trackedScreen.rawValue
        Analytics.setScreenName(screenName, screenClass: nil)
    }

    func configureDynamicAction() {

    }
}
