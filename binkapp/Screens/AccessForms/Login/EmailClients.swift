//
//  EmailClients.swift
//  binkapp
//
//  Created by Sean Williams on 19/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

enum EmailClients: String, CaseIterable {
    case mail
    case gmail
    case outlook
    
    var url: String {
        switch self {
        case .mail:
            return "message://"
        case .gmail:
            return "googlegmail:///"
        case .outlook:
            return "ms-outlook://"
        }
    }
    
    static func availableEmailClientsForDevice() -> [EmailClients] {
        var availableClients: [EmailClients] = []
        
        allCases.forEach {
            if let url = URL(string: $0.url), UIApplication.shared.canOpenURL(url) {
                availableClients.append($0)
            }
        }
        return availableClients
    }

    func open() {
        if let safeURL = URL(string: url), UIApplication.shared.canOpenURL(safeURL) {
            UIApplication.shared.open(safeURL, options: [:])
        }
    }
}
