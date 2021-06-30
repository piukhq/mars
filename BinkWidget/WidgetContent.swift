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
    case addCard = "addCard"
}

struct WidgetContent: TimelineEntry, Codable {
    var date = Date()
    let walletCards: [MembershipCardWidget]
}

struct MembershipCardWidget: Hashable, Codable {
    let id: String
    let imageData: Data?
    let backgroundColor: String?
    var url: URL {
        URL(string: "quicklaunch-widget://" + id) ?? URL(string: "quicklaunch-widget://")!
    }
}
