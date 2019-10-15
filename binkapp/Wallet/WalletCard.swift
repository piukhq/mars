//
//  WalletCard.swift
//  binkapp
//
//  Created by Nick Farrant on 11/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import CoreData

enum WalletCardType {
    case loyalty
    case payment
    case join
}

typealias WalletCard = WalletCardProtocol & NSManagedObject

protocol WalletCardProtocol {
    var id: String! { get }
    var type: WalletCardType { get }
}
