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
    
    // These cookies didn't last more than an hour
    // We'd need to persist login details and log them in every time?
    // But how do we login?
    
    static func scrapeUrl(_ url: String) {
        AF.request(url, headers: ["Cookie":"ADRUM=s=1591701183544&r=https%3A%2F%2Fsecure.tesco.com%2FClubcard%2FMyAccount%2Fhome%2FHome%3F0; akavpau_tesco_secure_clubcard=1591701406~id=6650041811d70e6fd8285ca2d28cf689; mca_tid=28eed8d4-29a1-4bc5-8c3b-466e81c50752; __utma=148719026.1278694460.1591631707.1591633391.1591700373.2; __utmb=148719026.4.9.1591700877140; __utmc=148719026; __utmt=1; __utmz=148719026.1591700373.2.2.utmcsr=tesco.com|utmccn=(referral)|utmcmd=referral|utmcct=/; optimizelyEndUserId=oeu1591633390875r0.17043282051792408; s_cc=true; s_fid=2DF8CD4A3D6A291C-343987F2C4FAC645; s_vi=[CS]v1|2F6F2FA18515C48B-40000817445B7F95[CE]; _sdsat_UUID=cceb4892-fb9b-4afb-bbd4-31a4bf529722; s_sq=%5B%5BB%5D%5D; _tid=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmNnBzNnA4SXk5emJRVHdJN0Y0d1NBPT0iOiJJaTFqRmpOdWNTbW9zS1hqL3RBajJBPT0iLCJ1RUhNS0VFYlBqQlI5dHpONWs1bFp3PT0iOiJ1VDJyTlU3RHFrZTdiKzNJKzB6VjdnPT0iLCJVVUlEIjoiY2NlYjQ4OTItZmI5Yi00YWZiLWJiZDQtMzFhNGJmNTI5NzIyIiwiYWNjZXNzVG9rZW4iOiI3OTZjZTVjOC0xOWMyLTQxMmEtODBhOC0xYmI1ODdkYzk0Y2YiLCJleHAiOjE1OTE3MDQ1MTYsImN1c3RvbWVyTWFpbFN0YXR1cyI6IjEiLCJjdXN0b21lclVzZVN0YXR1cyI6IjEiLCJBY3RpdmF0ZWQiOiJZIiwiaXNMZWZ0U2NoZW1lIjpmYWxzZSwiaXNCYW5uZWQiOmZhbHNlLCJpczJMQUNsZWFyZWQiOmZhbHNlLCJTZWN1cml0eVN0YXRlIjoiYmdCZ3JFV2V4b2xaOEJnTUpkVDk3WURWRVkrSmNQRHB3L2pRdWUrNGhKMD0iLCJJc3N1ZUJ5IjoiTUNBX01WQyIsImY2cHM2cDhJeTl6aTAwTi81VTQ2R2c9PSI6ImtYSXZNQVlidU0xNm41NzlYTTVJcFdqeUlTMStWS3ZWRkkvWUh6RnZYYjJOUm9CWDdWdEluWHN0UUZwU0FWZnlpaUZjSHc5eWxFcm52TENJdElrQXBOQzNJb2paVmZrK1dSVlJONmo0eFNmUEoyZGczY0hvbWJVWlE0eFZVL1Qvb3djcThKVkk0NldUZklNN1pCS0k5bHdjdm9TNzdiREJyelRJYWR6UEtwS2VWdnlOcHQyYXB3TmxZQlNVUEI3NDlvRXJzcVZmcTI1aCtuYUZnaktkYWxhNjBrRTBQNFJMRDhCQlh6OUpPOUIwWGhJbTVpYkdOTzBZWS9BWXdFWmtjRlRmaDhQNHFuMFpvVTljdVZpZEZZcFgyT0dKVlljSElQSXZocmxjdzVDRUN0dk5GN04vUkZoTjJIMnNNL3pkK0ZJL3lTY1dLY0FuMHM0ZXQ1ektjaDdXalVYYkF0dzIwTXFaaEVkZWdhSDNUMVJVczF6NFUwWGl4Y3kxaGc1bHZ3SURrOVhMc2VZc0JRQmxTTjRnY0Z3cWYwYjM3ZTc2SSt2T25aUUY4M2d6OS9xa0N6dDVVQXgyWG8wYnA1Ri9sekY5WlpCN0dLejFQU29mNFdiNFlqamdmcmNSd1ZaTmlvSTF3aFVQS1hpTmYweXp3TFlTMXcrcHR0elNuS1MxRlRDQTZlN0YyYkR1MjB0TVpJSEtnSDZxNzh0VEx6Z2JDZkh2QzdnSGxvOXpZenZkV3U0Z3p3PT0iLCJJc01lcmdlZCI6ZmFsc2V9.f4flo0BMC6_61SAgcpNI1nGiKV1dMn7byT5brbjpROg; s_gpv_pn=homepage; s_nr=1591700928772-Repeat; AMCV_E4860C0F53CE56C40A490D45%40AdobeOrg=281789898%7CMCIDTS%7C18422%7CMCMID%7C64771572759976536134136857147661994683%7CMCAID%7C2F6F2FA18515C48B-40000817445B7F95%7CMCOPTOUT-1591708117s%7CNONE%7CMCAAMLH-1592305717%7C6%7CMCAAMB-1592305717%7Cj8Odv6LonN4r3an7LhD3WZrU1bUpAkFkkiY1ncBR96t2PTI%7CvVersion%7C4.1.0%7CMCSYNCSOP%7C411-18429; atrc=f7e3e53d-2b48-4db6-99df-8507c2b07aac; s_ecid=MCMID%7C64771572759976536134136857147661994683; _ga=GA1.2.1278694460.1591631707; _gid=GA1.2.2073480295.1591631707; OAuth.RefreshToken=48f645ed-6df0-4824-a6d2-7c317621e97f; CID=51409438; DCACC=AWS1; OAuth.AccessToken=796ce5c8-19c2-412a-80a8-1bb587dc94cf; OAuth.TokensExpiryTime=%7B%22AccessToken%22%3A1591704516185%2C%22RefreshToken%22%3A1591708116185%7D; UUID=cceb4892-fb9b-4afb-bbd4-31a4bf529722; mytesco_from=%2F; trm=Jk%2BwYIjAjhxx%2BE1WOU5J1VvxpGCUQCXT2vcLRNwgvk93DwiV8HCOVat%2FKjhC%2BCwj%2BUK2LNrD6c7rl%2FEABPlEN%2BiQJuU26SInJkePQBoBAaiohsqAdNSWGisCrXd4oDD%2F1S0zyhiIH9A1ydXGYfIMRcnxfpRV%2Bp81k0GxTqTQP8CxmUZp4tIMTF%2BiPw%3D%3D; akavpau_tesco_secure=1591701216~id=be7b9763de2c95beb95ff288b4252adc; __gads=ID=d0a74242e728caf6-2291969271b6001d:T=1591631708:RT=1591700880:S=ALNI_MZnRsdb2r7jB5kAQaIbwpTGy_gPvw; DCIMG=SDC_TIL; bm_sz=54FEBF73050BADDCD25CA206FFE8F0F6~YAAQGA8DF13ycIdyAQAAGsm6mAjJKUvIQMxnanwi2bPYHHGnREZeafUqUhjGBu45ROQK3Cp9MTxHGlBJzcWFAe/1U2RWnVZb3AIqPeq4FqezsuzxewKSkTKkKAVDKIVHmBGn1kVNy1+Ox8ceu64tnlvMHrbGuk8+/1xg3nBZ9+kxeM1qbHNexzLhy94Ew8I=; myaccount_segment_changeClubcard=%7B%22segment%22%3A%22new%22%2C%22weighting%22%3A100%7D; myaccount_segment_dietaryNeedsLink=%7B%22segment%22%3A%22enabled%22%2C%22weighting%22%3A100%7D; myaccount_segment_mergeNotificationBanner=%7B%22segment%22%3A%22disabled%22%2C%22weighting%22%3A100%7D; myaccount_segment_oauthConnectedServices=%7B%22segment%22%3A%22disabled%22%2C%22weighting%22%3A100%7D; myaccount_segment_oauthConsent=%7B%22segment%22%3A%22enabled%22%2C%22weighting%22%3A100%7D; myaccount_segment_singleAddressBook=%7B%22segment%22%3A%22disabled%22%2C%22weighting%22%3A90%7D; myaccount_segment_splitNotificationBanner=%7B%22segment%22%3A%22enabled%22%2C%22weighting%22%3A100%7D; myaccount_segment_statementPreferences=%7B%22segment%22%3A%22disabled%22%2C%22weighting%22%3A100%7D; tesco_cookie_accepted=1; _csrf=H-tJVWEas3ExRGLO02BSWbnZ; AMCVS_E4860C0F53CE56C40A490D45%40AdobeOrg=1; _abck=F419FD998476B41F01EFC8F9DA56E00C~0~YAAQmOEWAnM5EYdyAQAA+ByklATAxtmQg6xnXfZEK6zQ3Wi5DCuURQrjEPQFQlIsS+UgYWERBM9+fFl+hQ73WNXfj1/30PDeCDgeLCr2Vr9g9gHi7qKSlWwfibXrcxB69s5Nhkle8rraibe2Cfq35XN1BAPeW+zGKqAE68532PoTDMB6SW4MF0X59dEQcRiCMKnZULOSSm11iv+1+bsSEb2VKdEF0zu7+ehDUluLYs6YDwEqTyof+qDI6ZUH/jm4xEXysQDTiC2uwXWEO//ZnOjL31438mjS7koJznP+uRFz6sopDZVmGlC9M1Q+ISVoI+r6VgYf~-1~-1~-1; mytesco_segment_jwtflag=%7B%22segment%22%3A%22disabled%22%2C%22weighting%22%3A95%7D; ASP.NET_SessionId=bxxk4f2of5udkowdwncs0f25; cookiesAccepted=1; mytesco_segment_notification=%7B%22segment%22%3A%22withoutMergeInterrupt%22%2C%22weighting%22%3A100%7D"]).response { response in
            debugPrint(response)
            if let html = try? response.result.get() {
                parseHTML(html: String(data: html, encoding: .utf8))
            }
        }
    }
    
    static func parseHTML(html: String?) {
        let doc = try! Kanna.HTML(html: html!, encoding: .utf8)

        for field in doc.css("span[class='pointvalue']") {
            print("WebScrapingUtility --- I have \(field.text ?? "<unknown>") Clubcard points")
        }
    }
}
