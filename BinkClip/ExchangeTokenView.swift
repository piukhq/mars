//
//  ExchangeTokenView.swift
//  BinkClip
//
//  Created by Sean Williams on 11/11/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import StoreKit
import SwiftUI

struct ExchangeTokenView: View {
    @State var token = ""
    @ObservedObject var client = APIClientAppClip()
    @State private var showRecommended = false
    
    var body: some View {
        if client.magicLinkToken.isEmpty {
            ProgressView()
        }

        Text(showRecommended ? "Account successfully created - please install the Bink App via the link below..." : "Setting up your Bink account...")
            .padding()
            .onAppear {
                client.requestMagicLinkAccesstoken(token)
            }
            .onChange(of: client.magicLinkToken) { newValue in
                showRecommended = true
            }
            .appStoreOverlay(isPresented: $showRecommended) {
                SKOverlay.AppConfiguration(appIdentifier: "HC34M8YE55.com.bink.wallet", position: .bottomRaised)
            }
    }
    
    func storeTokenInContainer() {
//        guard let archiveURL = FileManager.sharedContainerURL()?.appendingPathComponent("contents.json") else { return contents }
//
//        let decoder = JSONDecoder()
//        if let data = try? decoder.decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: <#T##Data#>)
    }
}

struct ExchangeTokenView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeTokenView()
    }
}
