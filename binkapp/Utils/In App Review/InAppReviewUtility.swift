//
//  InAppReviewUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 04/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import StoreKit

protocol InAppReviewable {
    func requestInAppReview()
}

extension InAppReviewable {
    func requestInAppReview() {
        guard canRequestReview else { return }
        SKStoreReviewController.requestReview()
    }

    private var canRequestReview: Bool {
        return true
    }
}
