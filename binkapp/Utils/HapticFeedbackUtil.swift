//
//  HapticFeedbackUtil.swift
//  binkapp
//
//  Created by Nick Farrant on 02/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

enum HapticFeedbackUtil {
    enum FeedbackType {
        case impact(style: UIImpactFeedbackGenerator.FeedbackStyle)
        case selection
        case notification(type: UINotificationFeedbackGenerator.FeedbackType)
    }

    static func giveFeedback(forType type: FeedbackType) {
        switch type {
        case .impact(let style):
            giveImpactFeedback(withStyle: style)
        case .selection:
            giveSelectionFeedback()
        case .notification(let type):
            giveNotificationFeedback(withType: type)
        }
    }

    private static func giveImpactFeedback(withStyle style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: style)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }

    private static func giveSelectionFeedback() {
        let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        selectionFeedbackGenerator.selectionChanged()
    }

    private static func giveNotificationFeedback(withType type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(type)
    }
}
