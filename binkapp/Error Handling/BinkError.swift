//
//  BinkError.swift
//  binkapp
//
//  Created by Nick Farrant on 15/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

enum BinkErrorDomain: Int {
    case networking
    case configuration
    case walletService
    case userService
    case webScrapingUtility
    case pointsScrapingManager
}

protocol BinkError: Error {
    var domain: BinkErrorDomain { get }
    var message: String { get }
}

extension BinkError {
    var localizedDescription: String {
        return message
    }
}
