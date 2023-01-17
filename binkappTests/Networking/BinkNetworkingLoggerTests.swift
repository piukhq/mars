//
//  BinkNetworkingLoggerTests.swift
//  binkappTests
//
//  Created by Sean Williams on 01/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Mocker
import XCTest
@testable import binkapp

// swiftlint:disable all

final class BinkNetworkingLoggerTests: XCTestCase, CoreDataTestable {
    static var baseMembershipCardResponse: MembershipCardModel!
    static var paymentCardCardResponse: PaymentCardCardResponse!
    static var basePaymentCardResponse: PaymentCardModel!
    static let linkedResponse = LinkedCardResponse(id: 300, activeLink: true)
    static var membershipCard: CD_MembershipCard!
    static var paymentCard: CD_PaymentCard!
    static var baseSut = PLLScreenViewModel(membershipCard: membershipCard, journey: .newCard)
    
    override class func setUp() {
        super.setUp()
        deleteExisitingLogs()
        
        // Membership Card
        baseMembershipCardResponse = MembershipCardModel(apiId: 300, membershipPlan: 500, membershipTransactions: nil, status: nil, card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil, openedTime: nil)

        mapResponseToManagedObject(baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
        }
        
        persistValidPaymentCard()
    }
    
    static private func persistValidPaymentCard() {
        paymentCardCardResponse = PaymentCardCardResponse(apiId: 100, firstSix: nil, lastFour: "1234", month: 30, year: 3000, country: nil, currencyCode: nil, nameOnCard: "Sean Williams", provider: nil, type: nil)
        
        Self.basePaymentCardResponse = PaymentCardModel(apiId: 100, membershipCards: [Self.linkedResponse], status: "active", card: paymentCardCardResponse, account: PaymentCardAccountResponse(apiId: 0, verificationInProgress: nil, status: 0, consents: []))
        
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
        }
    }
    
    private func mockPaymentCardLinkingRequest() {
        Current.apiClient.testResponseData = nil
        let mockedPaymentCard = try! JSONEncoder().encode(Self.basePaymentCardResponse)
        let endpoint = APIEndpoint.linkMembershipCardToPaymentCard(membershipCardId: Self.membershipCard.id, paymentCardId: Self.basePaymentCardResponse.id)
        let mock = Mock(url: URL(string: endpoint.urlString!)!, dataType: .json, statusCode: 200, data: [.post: mockedPaymentCard])
        mock.register()
    }
    
    private func mockAddMembershipCardRequest(with model: MembershipCardPostModel) {
        let mockedMembershipCard = try! JSONEncoder().encode(model)
        let endpoint = APIEndpoint.membershipCards.urlString ?? ""
        let mock = Mock(url: URL(string: endpoint)!, dataType: .json, statusCode: 200, data: [.post: mockedMembershipCard])
        mock.register()
    }
    
    private static func deleteExisitingLogs() {
        Current.apiClient.binkNetworkingLogger.logs = []
        do {
            if let url = Current.apiClient.binkNetworkingLogger.networkLogsFilePath() {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func test_01_loggerInitializesLogs_successfully() {
        let membershipCardPostModel = MembershipCardPostModel(account: nil, membershipPlan: 1)
        mockAddMembershipCardRequest(with: membershipCardPostModel)
        
        let authAndAddRepo = AuthAndAddRepository()
        authAndAddRepo.addMembershipCard(withRequestModel: membershipCardPostModel, existingMembershipCard: nil) { success, error in }
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 10.0)

        XCTAssertNotNil(Current.apiClient.binkNetworkingLogger.logs)
    }
    
    func test_02_loggerSavesLogs_successfully() {
        mockPaymentCardLinkingRequest()
        
        Self.baseSut.toggleLinkForMembershipCards { _ in }
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 10.0)

        XCTAssertFalse(Current.apiClient.binkNetworkingLogger.logs.isEmpty)
    }
    
    func test_03_loggerRequestContainsNoDataTask() {
        let logs = Current.apiClient.binkNetworkingLogger.logs
        APIClient().performEmptyRequest()
        XCTAssertTrue(logs.first?.endpoint == Current.apiClient.binkNetworkingLogger.logs.first?.endpoint)
    }
    
    func test_04_loggerLimitsLogCountToTwenty() {
        let membershipCardPostModel = MembershipCardPostModel(account: nil, membershipPlan: 1)
        mockAddMembershipCardRequest(with: membershipCardPostModel)

        let authAndAddRepo = AuthAndAddRepository()
        for _ in 0...20 {
            authAndAddRepo.addMembershipCard(withRequestModel: membershipCardPostModel, existingMembershipCard: nil) { success, error in }
        }
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 10.0)
        
        XCTAssertEqual(Current.apiClient.binkNetworkingLogger.logs.count, 20)
    }
}