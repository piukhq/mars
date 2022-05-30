//
//  BinkSupportUtility.swift
//  binkapp
//
//  Created by Sean Williams on 27/05/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation

enum BinkSupportUtility {
    private static let faqsURL = "https://help.gb.bink.com"
    
    static func launchContactSupport() {
        if EmailClient.availableEmailClientsForDevice().isEmpty {
            let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.supportMailNoEmailAppsTitle, message: L10n.supportMailNoEmailAppsBody)
            let navigationRequest = AlertNavigationRequest(alertController: alert)
            Current.navigate.to(navigationRequest)
        } else {
            EmailClient.openDefault(address: "support@bink.com", subject: "Bink App \(Bundle.currentVersion?.versionString ?? "") - Support Request")
        }
    }
    
    static func launchFAQs() {
        let webViewController = ViewControllerFactory.makeWebViewController(urlString: faqsURL)
        let navigationRequest = ModalNavigationRequest(viewController: webViewController)
        Current.navigate.to(navigationRequest)
    }
}
