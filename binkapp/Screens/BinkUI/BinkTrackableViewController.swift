//
//  BinkTrackableViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 23/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class BinkTrackableViewController: UIViewController {
    func setScreenName(trackedScreen: TrackedScreensEnum) {
        Analytics.setScreenName(trackedScreen.rawValue, screenClass: nil)
    }
}
