//
//  ContentView.swift
//  BinkClip
//
//  Created by Sean Williams on 11/11/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Alamofire
import AuthenticationServices
import SwiftUI

struct RegisterView: View {
    @State var emailAddress: String = ""
    @State var siwaDidSucceed = false

    let client = APIClientAppClip()
    var siwa = true
    
    var body: some View {
        if siwa {
            SignInWithAppleButton(.signUp) { _ in } onCompletion: { result in
                switch result {
                case .success(let auth):
                    guard let archiveURL = FileManager.sharedContainerURL()?.appendingPathComponent("contents.json") else { return }
                    guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
                    let encoder = JSONEncoder()
                    if let dataToSave = try? encoder.encode(credential.user) {
                        do {
                            try dataToSave.write(to: archiveURL)
                            
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            Text("Register with Bink using your email address, we'll send you a Magic Link to create an account.")
                .padding()
            TextField("Enter your email address", text: $emailAddress)
                .padding()
                .textFieldStyle(.roundedBorder)
            Button("Send Magic Link") {
                client.sendMagicLink(to: emailAddress)
            }
        }
        
        NavigationLink(destination: SIWAResultView(shouldDownloadApp: true), isActive: $siwaDidSucceed) {
            EmptyView()
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
