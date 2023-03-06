//
//  PreviousUpdatesViewModel.swift
//  binkapp
//
//  Created by Ricardo Silva on 06/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation

class PreviousUpdatesViewModel: ObservableObject {
    @Published var items: [RemoteConfigFile.ReleaseGroup] = []
    
    init() {
        items = Current.remoteConfig.configFile?.releases ?? []
    }
}
