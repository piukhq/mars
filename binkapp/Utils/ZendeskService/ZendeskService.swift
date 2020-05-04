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

    static func start() {
        Zendesk.initialize(appId: ZendeskService.appId, clientId: ZendeskService.clientId, zendeskUrl: ZendeskService.url)
        Support.initialize(withZendesk: Zendesk.instance)
        let identity = Identity.createAnonymous(name: nil, email: Current.userManager.currentEmailAddress)
        Zendesk.instance?.setIdentity(identity)
    }
}
