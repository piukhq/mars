//
//  WidgetContent.swift
//  binkapp
//
//  Created by Sean Williams on 24/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import WidgetKit

struct WidgetContent: TimelineEntry, Codable {
    var date = Date()
    let hasCurrentUser: Bool
    let walletCards: [MembershipCardWidget]
}

struct MembershipCardWidget: Hashable, Codable {
    let id: String
    let imageData: Data?
    let backgroundColor: String
    let isLight: Bool
    let cardNumber: String
}
