//
//  ExchangeTokenView.swift
//  BinkClip
//
//  Created by Sean Williams on 11/11/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct ExchangeTokenView: View {
    @State var token = ""
    let client = APIClientAppClip()
    
    var body: some View {
        ProgressView()
        Text("Setting up your Bink account...")
            .padding()
            .onAppear {
                client.requestMagicLinkAccesstoken(token)
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
