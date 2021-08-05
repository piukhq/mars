//
//  WidgetContent.swift
//  binkapp
//
//  Created by Sean Williams on 24/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import SwiftUI
import WidgetKit

enum WidgetUrlPath: String {
    case addCard = "add_button"
    case signIn = "sign_in"
    case spacerZero
    case spacerOne
}

enum WidgetType {
    case quickLaunch
    
    var identifier: String {
        switch self {
        case .quickLaunch:
            return  "com.bink.wallet.quicklaunchwidget"
        }
    }
    
    var userDefaultsSuiteID: String {
        switch self {
        default:
            return "group.com.bink.wallet"
        }
    }
    
    func isInstalled(widgetIDs: [String]) -> Bool {
        if widgetIDs.contains(identifier) {
            return true
        }
        return false
    }
}

struct WidgetContent: TimelineEntry, Codable {
    var date = Date()
    let walletCards: [MembershipCardWidget]
    var isPreview = false
}

struct MembershipCardWidget: Hashable, Codable {
    let id: String
    let imageData: Data?
    let backgroundColor: String?
    var url: URL {
        URL(string: "quicklaunch-widget://" + id) ?? URL(string: "quicklaunch-widget://")!
    }
}
