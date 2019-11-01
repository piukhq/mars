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
    func delete<T: WalletCard>(_ card: T, completion: @escaping () -> Void)
}

protocol PaymentWalletRepositoryProtocol: WalletRepository {
    func addPaymentCard(_ paymentCard: PaymentCardCreateModel, completion: @escaping (Bool) -> Void)
}
