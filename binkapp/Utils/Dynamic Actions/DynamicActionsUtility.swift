//
//  DynamicActionsUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 25/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct DynamicActionsUtility {
    func availableAction(for viewController: BinkViewController) -> DynamicAction? {
        guard let availableActions = availableActions(for: viewController) else { return nil }
        /// We really should only ever have one ACTIVE action available.
        /// If for some reason there are multiple, we're just going to pick the first one.
        /// We could sort them by start date and decide which to show based on that, but it feels like over-engineering.
        return availableActions.first
    }

    private func availableActions(for viewController: BinkViewController) -> [DynamicAction]? {
        /// From all of the actions that we received from the remote config, are there any that contain a location with a screen that matches the screen we are currently on?
        let availableActions = allActions?.filter { $0.locations?.contains(where: { $0.screen?.viewControllerType == type(of: viewController) }) == true }
        return availableActions?.filter { $0.isActive }
    }

    private var allActions: [DynamicAction]? {
        return Current.remoteConfig.objectForConfigKey(.dynamicActions, forObjectType: [DynamicAction].self)
    }
}
