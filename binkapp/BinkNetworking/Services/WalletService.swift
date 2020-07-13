//
//  WalletService.swift
//  binkapp
//
//  Created by Nick Farrant on 21/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

/// Used when there isn't an object being passed into the completion handler, just a success bool where it makes sense not to complicate things with Result.
typealias ServiceCompletionSuccessHandler<ErrorType: BinkError> = (Bool, ErrorType?) -> Void

/// Used when we need to pass an object or set of objects through the completion handler rather than just a success bool.
typealias ServiceCompletionResultHandler<ObjectType: Any, ErrorType: BinkError> = (Result<ObjectType, ErrorType>) -> Void

enum WalletServiceError: BinkError {
    case failedToGetMembershipPlans
    case failedToGetMembershipCards
    case failedToGetPaymentCards
    case failedToGetLoyaltyWallet
    case customError(String?)

    var domain: BinkErrorDomain {
        return .walletService
    }

    var message: String {
        return ""
    }
}

protocol WalletServiceProtocol {
    func getMembershipPlans(isUserDriven: Bool, completion: @escaping APIClientCompletionHandler<[MembershipPlanModel]>)
    func getMembershipCards(isUserDriven: Bool, completion: @escaping APIClientCompletionHandler<[MembershipCardModel]>)
    func getPaymentCards(isUserDriven: Bool, completion: @escaping APIClientCompletionHandler<[PaymentCardModel]>)
}

extension WalletServiceProtocol {
    func getMembershipPlans(isUserDriven: Bool, completion: @escaping APIClientCompletionHandler<[MembershipPlanModel]>) {
        let request = BinkNetworkRequest(endpoint: .membershipPlans, method: .get, headers: nil, isUserDriven: isUserDriven)
        Current.apiClient.performRequest(request, expecting: [MembershipPlanModel].self) { result in
            completion(result)
        }
    }

    func getMembershipCards(isUserDriven: Bool, completion: @escaping APIClientCompletionHandler<[MembershipCardModel]>) {
        let request = BinkNetworkRequest(endpoint: .membershipCards, method: .get, headers: nil, isUserDriven: isUserDriven)
        Current.apiClient.performRequest(request, expecting: [MembershipCardModel].self) { result in
            completion(result)
        }
    }

    func getPaymentCards(isUserDriven: Bool, completion: @escaping APIClientCompletionHandler<[PaymentCardModel]>) {
        let request = BinkNetworkRequest(endpoint: .paymentCards, method: .get, headers: nil, isUserDriven: isUserDriven)
        Current.apiClient.performRequest(request, expecting: [PaymentCardModel].self) { result in
            completion(result)
        }
    }
}
