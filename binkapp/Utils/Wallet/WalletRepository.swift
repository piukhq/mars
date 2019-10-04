//
//  WalletRepository.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

protocol WalletRepository: CoreDataRepositoryProtocol {
    init(apiManager: ApiManager)
}

struct PaymentWalletRepository: WalletRepository {
    private let apiManager: ApiManager

    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
}
