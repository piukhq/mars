//
//  WhatsNewViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 28/02/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

class WhatsNewViewModel: ObservableObject {
    init() {
        let features = Current.remoteConfig.configFile?.whatsNew?.features
        let merchants = Current.remoteConfig.configFile?.whatsNew?.merchants
        
        print(features?.first?.title)
        print(features?.first?.description)
        print(merchants)
        
    }
}
