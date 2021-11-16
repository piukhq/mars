//
//  APIClientAppClip.swift
//  binkapp
//
//  Created by Sean Williams on 12/11/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Alamofire
import SwiftUI
import Foundation

class APIClientAppClip: ObservableObject {
    let session: Session
    @Published var magicLinkToken = ""
    
    init() {
        session = Certificates.configureSession()
    }
    
    func sendMagicLink(to emailAddress: String) {
        let body = try? MagicLinkRequestModelAppClip(email: emailAddress).asDictionary()
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
    
    func requestMagicLinkAccesstoken(_ token: String) {
        let body = MagicLinkAccessTokenRequestModelAppClip(token: token)
        var headers: HTTPHeaders
        let userAgentHeader = HTTPHeader(name: "User-Agent", value: "Bink App / iOS 2.3.11 / 15.2")
        let contentTypeHeader = HTTPHeader(name: "Content-Type", value: "application/json")
        let acceptHeader = HTTPHeader(name: "Accept", value: "application/json;v=1.3")
        headers = [contentTypeHeader, acceptHeader, userAgentHeader]
        
        session.request("https://api.staging.gb.bink.com/users/magic_links/access_tokens", method: .post, parameters: body, encoder: JSONParameterEncoder.default, headers: headers).cacheResponse(using: ResponseCacher.doNotCache).responseJSON { response in
            print(response)
            switch response.result {
            case .success:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.magicLinkToken = "dhd897d8udhddyd9dyudhddidd"
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

    }
}

struct MagicLinkRequestModelAppClip: Codable {
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

struct MagicLinkAccessTokenRequestModelAppClip: Codable {
    let token: String
}
