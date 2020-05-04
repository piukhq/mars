//
//  ZendeskService.swift
//  binkapp
//
//  Created by Nick Farrant on 04/05/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

import ZendeskCoreSDK
import SupportSDK

final class ZendeskService {
//    private static let appId = "99f61aab44ade625ef0c3c98d72e2b3f00ae01beb8f54ddc"
//    private static let clientId = "mobile_sdk_client_bd8c22b8c88c29ff0667"
//    private static let url = "https://binkcx1573467900.zendesk.com"

    // PROD
    private static let appId = "933fc7d63c490c33e5fa62b1fe94070a219b8b0ffc8161d0"
    private static let clientId = "mobile_sdk_client_569de7fcd5547fac2361"
    private static let url = "https://binkcx.zendesk.com"

    static var shouldPromptForIdentity: Bool {
        let firstName = Current.userManager.currentFirstName ?? ""
        let lastName = Current.userManager.currentLastName ?? ""
        return firstName.isEmpty || lastName.isEmpty
    }

    static func start() {
        CoreLogger.enabled = true
        CoreLogger.logLevel = .debug
        Zendesk.initialize(appId: ZendeskService.appId, clientId: ZendeskService.clientId, zendeskUrl: ZendeskService.url)
        Support.initialize(withZendesk: Zendesk.instance)

        let firstName = Current.userManager.currentFirstName
        let lastName = Current.userManager.currentLastName
        setIdentity(firstName: firstName, lastName: lastName)
    }

    static func setIdentity(firstName: String?, lastName: String?) {
        guard let firstName = firstName, let lastName = lastName else {
            // If we can't set a complete identity, set it to nil
            setIdentity(fullName: nil)
            return
        }
        setIdentity(fullName: "\(firstName) \(lastName)")
    }

    private static func setIdentity(fullName: String?) {
        print("ZENDESK: Setting identity for \(fullName ?? "")")
        let identity = Identity.createAnonymous(name: fullName, email: Current.userManager.currentEmailAddress)
        Zendesk.instance?.setIdentity(identity)
    }
}
