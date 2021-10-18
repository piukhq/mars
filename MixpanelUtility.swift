//
//  MixpanelUtility.swift
//  
//
//  Created by Nick Farrant on 12/10/2021.
//

import Foundation
import Mixpanel
import Keys

struct MixpanelUtility {
    static let shared = Mixpanel.mainInstance()
    
    static func start() {
        Mixpanel.initialize(token: BinkappKeys().mixpanelToken)
    }
}
