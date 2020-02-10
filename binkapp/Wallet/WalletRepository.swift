//
//  WalletRepository.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

protocol WalletRepository: CoreDataRepositoryProtocol {
    typealias EmptyCompletionBlock = () -> Void
    init(apiManager: ApiManager)
    func delete<T: WalletCard>(_ card: T, completion: EmptyCompletionBlock?)
}

protocol PaymentWalletRepositoryProtocol: WalletRepository {
    func addPaymentCard(_ paymentCard: PaymentCardCreateModel, onSuccess: @escaping (CD_PaymentCard?) -> Void, onError: @escaping(Error?) -> Void)
}
