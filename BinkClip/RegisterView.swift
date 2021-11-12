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
    var session: Session
    
    init() {
        session = Certificates.configureSession()
    }

    
    var body: some View {
        Text("Register with Bink using your email address, we'll send you a Magic Link to create an account.")
            .padding()
        TextField("Enter your email address", text: $emailAddress)
            .padding()
        Button("Send Magic Link") {
            sendMagicLink()
        }
    }
    
    func sendMagicLink() {
        let body = try? MagicLinkRequestModel(email: emailAddress).asDictionary()
        var headers: HTTPHeaders
        let userAgentHeader = HTTPHeader(name: "User-Agent", value: "Bink App / iOS 2.3.11 / 15.2")
        let contentTypeHeader = HTTPHeader(name: "Content-Type", value: "application/json")
        let acceptHeader = HTTPHeader(name: "Accept", value: "application/json;v=1.3")
        headers = [contentTypeHeader, acceptHeader, userAgentHeader]

        session.request("https://api.staging.gb.bink.com/users/magic_links", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).cacheResponse(using: ResponseCacher.doNotCache).responseJSON { response in
            print("Magic link request sent")
            print(response.response as Any)
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

struct MagicLinkRequestModel: Codable {
    let email: String
    let slug: String
    let locale: String
    let bundleId: String
    
    init(email: String) {
        self.email = email
        self.slug = "iceland-bonus-card-mock"
        self.locale = "en_GB"
        self.bundleId = "com.bink.wallet"
    }
    
    enum CodingKeys: String, CodingKey {
        case email
        case slug
        case locale
        case bundleId = "bundle_id"
    }
}

struct MagicLinkAccessTokenRequestModel: Codable {
    let token: String
}
