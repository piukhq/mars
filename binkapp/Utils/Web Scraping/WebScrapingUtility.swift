//
//  WebScrapingUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 08/06/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import Kanna
import Alamofire

final class WebScrapingUtility {
    static func scrapeUrl(_ url: String) {
        AF.request(url).response { response in
            debugPrint(response)
            if let html = try? response.result.get() {
                parseHTML(html: String(data: html, encoding: .utf8))
            }
        }
    }
    
    static func parseHTML(html: String?) {
        
    }
}
