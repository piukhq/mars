//
//  binkappApp.swift
//  Bink Watch App Extension
//
//  Created by Nick Farrant on 03/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

@main
struct binkappApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                WatchContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
