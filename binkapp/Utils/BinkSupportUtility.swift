//
//  BinkSupportUtility.swift
//  binkapp
//
//  Created by Sean Williams on 27/05/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation

enum BinkSupportUtility {
    static func launchContactSupport() {
        if EmailClient.availableEmailClientsForDevice().isEmpty {
            let alert = ViewControllerFactory.makeOkAlertViewController(title: "No email app installed", message: "No Mail accounts set up, please email us directly: support@bink.com.")
            let navigationRequest = AlertNavigationRequest(alertController: alert)
            Current.navigate.to(navigationRequest)
        } else {
            EmailClient.openDefault(address: "support@bink.com", subject: "Bink App \(Bundle.currentVersion?.versionString ?? "") - Support Request")
        }
    }
}
