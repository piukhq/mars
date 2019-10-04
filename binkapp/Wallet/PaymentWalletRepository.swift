//
//  PaymentWalletRepository.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

struct PaymentWalletRepository: WalletRepository {
    typealias T = CD_PaymentCard

    private let apiManager: ApiManager

    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }

    func delete(_ card: CD_PaymentCard, completion: @escaping () -> Void) {
        //
    }
}
