//
//  WalletRepository.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CoreData

protocol WalletRepository: CoreDataRepositoryProtocol {
    associatedtype T

    init(apiManager: ApiManager)
    func delete(_ card: T, completion: @escaping () -> Void)
}
