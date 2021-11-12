//
//  ContentView.swift
//  BinkClip
//
//  Created by Sean Williams on 11/11/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Alamofire
import SwiftUI

struct RegisterView: View {
    @State var emailAddress: String = ""
    let client = APIClientAppClip()
    
    var body: some View {
        Text("Register with Bink using your email address, we'll send you a Magic Link to create an account.")
            .padding()
        TextField("Enter your email address", text: $emailAddress)
            .padding()
        Button("Send Magic Link") {
            client.sendMagicLink(to: emailAddress)
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
