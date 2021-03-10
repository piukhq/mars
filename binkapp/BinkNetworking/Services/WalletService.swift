//
//  WalletService.swift
//  binkapp
//
//  Created by Nick Farrant on 21/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import Alamofire

enum WalletServiceError: BinkError {
    case failedToGetMembershipPlans
    case failedToGetMembershipCards
    case failedToGetPaymentCards
    case failedToGetLoyaltyWallet
    case failedToAddMembershipCard
    case failedToDeleteMembershipCard
    case failedToAddGhostCard
    case failedToGetPaymentCard
    case failedToGetSpreedlyToken
    case failedToAddPaymentCard
    case failedToDeletePaymentCard
    case failedToLinkMembershipCardToPaymentCard
    case customError(String)
    case userFacingNetworkingError(NetworkingError)

    var domain: BinkErrorDomain {
        return .walletService
    }

    var message: String {
        switch self {
        case .failedToGetMembershipPlans:
            return "Failed to get membership plans"
        case .failedToGetMembershipCards:
            return "Failed to get membership cards"
        case .failedToGetPaymentCards:
            return "Failed to get payment cards"
        case .failedToGetLoyaltyWallet:
            return "Failed to get loyalty wallet"
        case .failedToAddMembershipCard:
            return "Failed to add membership card"
        case .failedToDeleteMembershipCard:
            return "Failed to delete membership card"
        case .failedToAddGhostCard:
            return "Failed to add ghost card"
        case .failedToGetPaymentCard:
            return "Failed to get payment card"
        case .failedToGetSpreedlyToken:
            return "Failed to get Spreedly token"
        case .failedToAddPaymentCard:
            return "Failed to add payment card"
        case .failedToDeletePaymentCard:
            return "Failed to delete payment card"
        case .failedToLinkMembershipCardToPaymentCard:
            return "Failed to link membership card to payment card"
        case .customError(let message):
            return message
        case .userFacingNetworkingError(let error):
            return error.message
        }
    }
}

protocol WalletServiceProtocol {}

extension WalletServiceProtocol {
    func getMembershipPlans(isUserDriven: Bool, completion: @escaping ServiceCompletionResultHandler<[MembershipPlanModel], WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .membershipPlans, method: .get, headers: nil, isUserDriven: isUserDriven)
        Current.apiClient.performRequest(request, expecting: [MembershipPlanModel].self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.info(.fetchedMembershipPlans, value: "\(response.count) plans aquired", category: .walletService)
                }
                completion(.success(response))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(.fetchMembershipPlans, value: rawResponse?.urlResponse?.statusCode.description, category: .walletService)
                }
                completion(.failure(.failedToGetMembershipPlans))
            }
        }
    }

    func getMembershipCards(isUserDriven: Bool, completion: @escaping ServiceCompletionResultHandler<[MembershipCardModel], WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .membershipCards, method: .get, headers: nil, isUserDriven: isUserDriven)
        Current.apiClient.performRequest(request, expecting: [MembershipCardModel].self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.info(.fetchedMembershipCards, value: "\(response.count) cards aquired", category: .walletService)
                }
                completion(.success(response))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(.fetchMembershipCards, value: rawResponse?.urlResponse?.statusCode.description, category: .walletService)
                }
                completion(.failure(.failedToGetMembershipCards))
            }
        }
    }
    
    // TODO: Refactor?
    func addMembershipCard(withRequestModel model: MembershipCardPostModel, existingMembershipCard: CD_MembershipCard?, completion: @escaping ServiceCompletionResultRawResponseHandler<MembershipCardModel, WalletServiceError>) {
        let endpoint: APIEndpoint
        let method: HTTPMethod
        
        if let existingCard = existingMembershipCard {
            endpoint = .membershipCard(cardId: existingCard.id)
            method = .put
        } else {
            endpoint = .membershipCards
            method = .post
        }
        
        let request = BinkNetworkRequest(endpoint: endpoint, method: method, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithBody(request, body: model, expecting: MembershipCardModel.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                completion(.success(response), rawResponse)
            case .failure:
                completion(.failure(.failedToAddMembershipCard), rawResponse)
            }
        }
    }
    
    func addGhostCard(withRequestModel model: MembershipCardPostModel, completion: @escaping ServiceCompletionResultHandler<MembershipCardModel, WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .membershipCards, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithBody(request, body: model, expecting: MembershipCardModel.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(.ghostCardAdded, value: model.uuid, category: .walletService)
                }
                completion(.success(response))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(.addGhostCardFailure, value: rawResponse?.urlResponse?.statusCode.description, category: .walletService)
                }
                completion(.failure(.failedToAddGhostCard))
            }
        }
    }
    
    func patchGhostCard(withRequestModel model: MembershipCardPostModel, existingMembershipCard: CD_MembershipCard, completion: @escaping ServiceCompletionResultHandler<MembershipCardModel, WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .membershipCard(cardId: existingMembershipCard.id), method: .patch, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithBody(request, body: model, expecting: MembershipCardModel.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(.ghostCardUpdated, value: existingMembershipCard.id, category: .walletService)
                }
                completion(.success(response))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(.updateGhostCardFailure, value: rawResponse?.urlResponse?.statusCode.description, category: .walletService)
                }
                completion(.failure(.failedToAddGhostCard))
            }
        }
    }
    
    func deleteMembershipCard(_ membershipCard: CD_MembershipCard, completion: ServiceCompletionSuccessResponseDataHandler<WalletServiceError>?) {
        let request = BinkNetworkRequest(endpoint: .membershipCard(cardId: membershipCard.id), method: .delete, headers: nil, isUserDriven: false)
        Current.apiClient.performRequestWithNoResponse(request, body: nil) { (success, _, responseData) in
            guard success else {
                completion?(false, .failedToDeleteMembershipCard, responseData)
                return
            }
            completion?(true, nil, responseData)
        }
    }

    func getPaymentCards(isUserDriven: Bool, completion: @escaping ServiceCompletionResultHandler<[PaymentCardModel], WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .paymentCards, method: .get, headers: nil, isUserDriven: isUserDriven)
        Current.apiClient.performRequest(request, expecting: [PaymentCardModel].self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.info(.fetchedPaymentCards, value: "\(response.count) cards aquired", category: .walletService)
                }
                completion(.success(response))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(.fetchPaymentCards, value: rawResponse?.urlResponse?.statusCode.description, category: .walletService)
                }
                completion(.failure(.failedToGetPaymentCards))
            }
        }
    }

    func getPaymentCard(withId id: String, completion: @escaping ServiceCompletionResultHandler<PaymentCardModel, WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .paymentCard(cardId: id), method: .get, headers: nil, isUserDriven: false)
        Current.apiClient.performRequest(request, expecting: PaymentCardModel.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                if #available(iOS 14.0, *) {
                    BinkLogger.info(.fetchedPaymentCard, value: "\(response.id)", category: .walletService)
                }
                completion(.success(response))
            case .failure:
                if #available(iOS 14.0, *) {
                    BinkLogger.error(.fetchPaymentCard, value: rawResponse?.urlResponse?.statusCode.description, category: .walletService)
                }
                completion(.failure(.failedToGetPaymentCards))
            }
        }
    }
    
    func getSpreedlyToken(withRequest model: SpreedlyRequest, completion: @escaping ServiceCompletionResultHandler<SpreedlyResponse, WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .spreedly, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithBody(request, body: model, expecting: SpreedlyResponse.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure:
                SentryService.triggerException(.tokenisationServiceRejectedRequest(rawResponse))
                completion(.failure(.failedToGetSpreedlyToken))
            }
        }
    }
    
    func addPaymentCard(withRequestModel model: PaymentCardCreateRequest, completion: @escaping ServiceCompletionResultRawResponseHandler<PaymentCardModel, WalletServiceError>) {
        let params = ["autoLink": "true"]
        let request = BinkNetworkRequest(endpoint: .paymentCards, method: .post, queryParameters: params, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithBody(request, body: model, expecting: PaymentCardModel.self) { (result, rawResponse) in
            switch result {
            case .success(let response):
                completion(.success(response), rawResponse)
            case .failure:
                SentryService.triggerException(.apiRejectedRequest(rawResponse))
                completion(.failure(.failedToAddMembershipCard), rawResponse)
            }
        }
    }
    
    func deletePaymentCard(_ paymentCard: CD_PaymentCard, completion: ServiceCompletionSuccessResponseDataHandler<WalletServiceError>?) {
        let request = BinkNetworkRequest(endpoint: .paymentCard(cardId: paymentCard.id), method: .delete, headers: nil, isUserDriven: false)
        Current.apiClient.performRequestWithNoResponse(request, body: nil) { (success, _, responseData) in
            guard success else {
                completion?(false, .failedToDeletePaymentCard, responseData)
                return
            }
            completion?(true, nil, responseData)
        }
    }
    
    func toggleMembershipCardPaymentCardLink(membershipCard: CD_MembershipCard, paymentCard: CD_PaymentCard, shouldLink: Bool, completion: @escaping ServiceCompletionResultHandler<PaymentCardModel, WalletServiceError>) {
        let request = BinkNetworkRequest(endpoint: .linkMembershipCardToPaymentCard(membershipCardId: membershipCard.id, paymentCardId: paymentCard.id), method: shouldLink ? .patch : .delete, headers: nil, isUserDriven: false)
        Current.apiClient.performRequest(request, expecting: PaymentCardModel.self) { (result, response) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let networkError):
                if #available(iOS 14.0, *) {
                    BinkLogger.errorPrivate(shouldLink ? .pllLoyaltyCardLinkingFailure : .pllLoyaltyCardUnlinkingFailure, value: "\(response?.urlResponse?.statusCode ?? 0) - \(membershipCard.id ?? "")", category: .walletService)
                }
                
                if case .userFacingError = networkError {
                    completion(.failure(.userFacingNetworkingError(networkError)))
                } else {
                    completion(.failure(.failedToLinkMembershipCardToPaymentCard))
                }
            }
        }
    }
}
