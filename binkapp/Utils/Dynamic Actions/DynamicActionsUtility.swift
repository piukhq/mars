//
//  DynamicActionsUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 25/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct DynamicActionsUtility {
    var allActions: [DynamicAction]? {
        return Current.remoteConfig.objectForConfigKey(.dynamicActions, forObjectType: [DynamicAction].self)
    }

    func availableActions(for viewController: BinkViewController) -> [DynamicAction]? {
        /// From all of the actions that we received from the remote config, are there any that contain a location with a screen that matches the screen we are currently on?
        let availableActions = allActions?.filter { $0.locations?.contains(where: { $0.screen?.viewControllerType == type(of: viewController) }) == true }
        // TODO: Are any of the available actions within the timeframe?
        return availableActions
    }
}
