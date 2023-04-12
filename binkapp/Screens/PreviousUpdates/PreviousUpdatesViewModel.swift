//
//  PreviousUpdatesViewModel.swift
//  binkapp
//
//  Created by Ricardo Silva on 06/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation
import UIKit

class PreviousUpdatesViewModel: ObservableObject {
    @Published var items: [RemoteConfigFile.ReleaseGroup] = []
    
    init() {
        if UIApplication.isRunningUnitTests {
            if let filePath = Bundle.main.path(forResource: "fireBase-config", ofType: "json") {
                do {
                    if let data = try String(contentsOfFile: filePath).data(using: .utf8) {
                        let conf = try JSONDecoder().decode(RemoteConfigFile.self, from: data)
                        self.items = conf.releases ?? []
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        } else {
            self.items = Current.remoteConfig.configFile?.releases ?? []
        }
    }
}
