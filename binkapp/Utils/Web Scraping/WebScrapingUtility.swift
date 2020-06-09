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
        AF.request(url, headers: ["Cookie":"_tid=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmNnBzNnA4SXk5emJRVHdJN0Y0d1NBPT0iOiJJaTFqRmpOdWNTbW9zS1hqL3RBajJBPT0iLCJ1RUhNS0VFYlBqQlI5dHpONWs1bFp3PT0iOiJ1VDJyTlU3RHFrZTdiKzNJKzB6VjdnPT0iLCJVVUlEIjoiY2NlYjQ4OTItZmI5Yi00YWZiLWJiZDQtMzFhNGJmNTI5NzIyIiwiYWNjZXNzVG9rZW4iOiI5OTk4NzdmNC0yZmNiLTQ2ZTktYmVhYi1hMWFmZTY5YjRlMjIiLCJleHAiOjE1OTE2MzY5ODksImN1c3RvbWVyTWFpbFN0YXR1cyI6IjEiLCJjdXN0b21lclVzZVN0YXR1cyI6IjEiLCJBY3RpdmF0ZWQiOiJZIiwiaXNMZWZ0U2NoZW1lIjpmYWxzZSwiaXNCYW5uZWQiOmZhbHNlLCJpczJMQUNsZWFyZWQiOmZhbHNlLCJTZWN1cml0eVN0YXRlIjoiYmdCZ3JFV2V4b2xaOEJnTUpkVDk3WURWRVkrSmNQRHB3L2pRdWUrNGhKMD0iLCJJc3N1ZUJ5IjoiTUNBX01WQyIsImY2cHM2cDhJeTl6aTAwTi81VTQ2R2c9PSI6ImtYSXZNQVlidU0xNm41NzlYTTVJcFdqeUlTMStWS3ZWRkkvWUh6RnZYYjJOUm9CWDdWdEluWHN0UUZwU0FWZnlpaUZjSHc5eWxFcm52TENJdElrQXBOQzNJb2paVmZrK1dSVlJONmo0eFNmUEoyZGczY0hvbWJVWlE0eFZVL1Qvb3djcThKVkk0NldUZklNN1pCS0k5bHdjdm9TNzdiREJyelRJYWR6UEtwS2VWdnlOcHQyYXB3TmxZQlNVUEI3NDlvRXJzcVZmcTI1aCtuYUZnaktkYWxhNjBrRTBQNFJMRDhCQlh6OUpPOUIwWGhJbTVpYkdOTzBZWS9BWXdFWmtjRlRmaDhQNHFuMFpvVTljdVZpZEZZcFgyT0dKVlljSElQSXZocmxjdzVDRUN0dk5GN04vUkZoTjJIMnNNL3pkK0ZJL3lTY1dLY0FuMHM0ZXQ1ektjaDdXalVYYkF0dzIwTXFaaEVkZWdhSDNUMVJVczF6NFUwWGl4Y3kxaGc1bHZ3SURrOVhMc2VZc0JRQmxTTjRnY0Z3cWYwYjM3ZTc2SSt2T25aUUY4M2d6OS9xa0N6dDVVQXgyWG8wYnA1Ri9sekY5WlpCN0dLejFQU29mNFdiNFlqamdmcmNSd1ZaTmlvSTF3aFVQS1hpTmYweXp3TFlTMXcrcHR0elNuS1MxRlRDQTZlN0YyYkR1MjB0TVpJSEtnSDZxNzh0VEx6Z2JDZkh2QzdnSGxvOXpZenZkV3U0Z3p3PT0iLCJJc01lcmdlZCI6ZmFsc2V9.9yl53Oen_UjFWhBYDU7ciRbd58ljO9TlVVrhFs7H-1Q; OAuth.RefreshToken=2906ac64-820b-4fc6-b7f6-093ed53b8b68; CID=51409438; DCACC=AWS1; OAuth.AccessToken=999877f4-2fcb-46e9-beab-a1afe69b4e22; OAuth.TokensExpiryTime=%7B%22AccessToken%22%3A1591636989295%2C%22RefreshToken%22%3A1591640589295%7D;"]).response { response in
            debugPrint(response)
//            if let html = try? response.result.get() {
//                parseHTML(html: String(data: html, encoding: .utf8))
//            }
        }
    }
    
//    static func parseHTML(html: String?) {
//        let doc = try! Kanna.HTML(html: html!, encoding: .utf8)
//
//        // Search for nodes by CSS selector
//        for field in doc.css("input[type='email']") {
//            print(field)
//        }
//    }
}
