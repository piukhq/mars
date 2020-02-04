//
//  RefreshControlExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 09/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

extension UIRefreshControl {
    func programaticallyBeginRefreshing(in collectionView: UICollectionView) {
        beginRefreshing()
        // The following are the values at which a collection view offsets it's content on a pull to refresh, which we want to mimic
        let notchDeviceOffsetY = -168.3
        let nonNotchDeviceOffsetY = -144.4
        let contentOffsetY = UIDevice.current.hasNotch ? notchDeviceOffsetY : nonNotchDeviceOffsetY
        let offsetPoint = CGPoint.init(x: 0, y: contentOffsetY)
        collectionView.setContentOffset(offsetPoint, animated: true)
    }
    
    func programaticallyEndRefreshing(in collectionView: UICollectionView, with navigationBar: UINavigationBar) {
        endRefreshing()
        // The following are collection view resting values in notch and non-notch devices
        let notchDeviceOffsetY = -108.0
        let nonNotchDeviceOffsetY = -84.0
        let contentOffsetY = UIDevice.current.hasNotch ? notchDeviceOffsetY : nonNotchDeviceOffsetY
        let offsetPoint = CGPoint.init(x: 0, y: contentOffsetY)
        collectionView.setContentOffset(offsetPoint, animated: true)
    }
}
