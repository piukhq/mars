//
//  DynamicActionsUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 25/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct DynamicActionsUtility {
    var availableActions: [DynamicAction]? {
        return Current.remoteConfig.objectForConfigKey(.dynamicActions, forObjectType: [DynamicAction].self)
    }
}
