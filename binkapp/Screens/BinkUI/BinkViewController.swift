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
    private let dynamicActionUtility = DynamicActionsUtility()
    var screenName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDynamicActionIfNecessary()
    }

    func setScreenName(trackedScreen: TrackedScreen) {
        screenName = trackedScreen.rawValue
        Analytics.setScreenName(screenName, screenClass: nil)
    }

    private func configureDynamicActionIfNecessary() {
        guard let availableActions = dynamicActionUtility.availableActions(for: self) else { return }
        guard let firstAction = availableActions.first else { return }
        guard let location = firstAction.location(for: self) else { return }
        print(location)
        let barButtonItem = UIBarButtonItem(title: "🎄", style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = barButtonItem
    }
}
