//
//  TescoPointsScrapingAgent.swift
//  binkapp
//
//  Created by Nick Farrant on 09/07/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

struct TescoScrapingAgent: WebScrapable {
    var merchantName: String {
        return "Tesco"
    }
    
    var loyaltySchemeName: String {
        return "Tesco Clubcard"
    }
    
    var loyaltySchemeBalanceIdentifier: String {
        return "pts"
    }
    
    var scrapableUrlString: String {
        return "https://secure.tesco.com/Clubcard/MyAccount/home/Home"
    }
    
    var loginScriptFileName: String {
        return "TescoLogin"
    }
    
    var pointsScrapingScriptFileName: String {
        return "TescoPointsScrape"
    }
}
