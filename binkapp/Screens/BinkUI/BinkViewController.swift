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
    private var dynamicAction: DynamicAction?

    var screenName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDynamicActionIfNecessary()
    }

    func setScreenName(trackedScreen: TrackedScreen) {
        screenName = trackedScreen.rawValue
        Analytics.setScreenName(screenName, screenClass: nil)
    }
}

// MARK: - Dynamic Actions

private extension BinkViewController {
    func configureDynamicActionIfNecessary() {
        // TODO: Do we need this? Just get the first action back
        guard let availableActions = dynamicActionUtility.availableActions(for: self) else { return }
        dynamicAction = availableActions.first
        guard let location = dynamicAction?.location(for: self) else { return }
        print(location)

        // TODO: Single tap or double tap?

        switch location.area {
        case .leftTopBar:
            guard let iconString = location.icon else { return }
            if let emoji = iconString.toEmoji() {
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: emoji, style: .plain, target: self, action: #selector(dynamicActionHandler))
            } else if let iconImage = UIImage(named: iconString) {
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: iconImage, style: .plain, target: self, action: #selector(dynamicActionHandler))
            }
        case .none:
            return
        }
    }

    @objc func dynamicActionHandler() {
        // Get view controller
        guard let dynamicAction = dynamicAction else { return }
        let viewModel = DynamicActionViewModel(dynamicAction: dynamicAction)
        let viewController = DynamicActionViewController(viewModel: viewModel)

        switch dynamicAction.event?.type {
        case .launchModal:
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        case .none:
            return
        }
    }
}

extension String {
    func toEmoji() -> String? {
        // Strip the payload value to just the unicode
        let trimStartIndex = index(startIndex, offsetBy: 2)
        let strippedCode = self[trimStartIndex..<endIndex]

        // Convert to numeric value
        guard let charCode = UInt32(strippedCode, radix: 16) else { return nil }
        guard let unicode = UnicodeScalar(charCode) else { return nil }
        return String(unicode)
    }
}
