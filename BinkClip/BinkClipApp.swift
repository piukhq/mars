//
//  BinkClipApp.swift
//  BinkClip
//
//  Created by Sean Williams on 11/11/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

@main
struct BinkClipApp: App {
    @State var token: String = ""
    
    var body: some Scene {
        WindowGroup {
            if token.isEmpty {
                RegisterView()
                    .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
            } else {
                ExchangeTokenView(token: token)
            }
        }
    }
    
    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard
            let incomingURL = userActivity.webpageURL,
            let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems
        else { return }
        
        print(queryItems)
        
        if let token = queryItems.first(where: { $0.name.starts(with: "token") }), let value = token.value {
            self.token = value
        }
    }
}
