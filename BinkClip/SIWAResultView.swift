//
//  SIWAResultView.swift
//  BinkClip
//
//  Created by Sean Williams on 16/11/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import StoreKit
import SwiftUI

struct SIWAResultView: View {
    @State var shouldDownloadApp = false
    
    var body: some View {
        Text("Your Bink account has been created, please download the Bink App from the App Store and you will be signed in automatically.")
            .appStoreOverlay(isPresented: $shouldDownloadApp) {
                SKOverlay.AppConfiguration(appIdentifier: "HC34M8YE55.com.bink.wallet", position: .bottomRaised)
            }
    }
}

struct SIWAResultView_Previews: PreviewProvider {
    static var previews: some View {
        SIWAResultView()
    }
}
