//
//  LayoutHelper.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

struct LayoutHelper { }

extension LayoutHelper {
    struct BinkInfoButton {
        static let imageEdgeInsets = UIEdgeInsets(top: 8, left: 6, bottom: 7, right: 5)
        static let titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
    }

    struct WalletDimensions {
        static let cardHeight: CGFloat = 120.0
        static let cardHorizontalPadding: CGFloat = 25.0
        static let cardLineSpacing: CGFloat = 12.0
        static let cardCornerRadius: CGFloat = 8.0
        static let edgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
}
