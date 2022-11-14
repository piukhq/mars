//
//  LoyaltyWalletViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 11/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class LoyaltyWalletViewModelTests: XCTestCase, CoreDataTestable {
    
    static var membershipCard: CD_MembershipCard!
    static var membershipCardStatusModel: MembershipCardStatusModel!
    static var cardModel: CardModel!
    static var membershipCardBalanceModel: MembershipCardBalanceModel!
    static var baseMembershipCardResponse: MembershipCardModel!
    static var membershipPlanResponse: MembershipPlanModel!
    static var membershipPlan: CD_MembershipPlan!
    static var featureSetResponse: FeatureSetModel!
    static var planAccountResponse: MembershipPlanAccountModel!
    static var voucherResponse: VoucherModel!
    static var voucher: CD_Voucher!
    static var model: LoyaltyWalletViewModel!
    
    override class func setUp() {
        super.setUp()
        
        featureSetResponse = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: true)
        let enrolField = EnrolFieldModel(apiId: nil, column: nil, validation: nil, fieldDescription: nil, type: nil, choices: [], commonName: nil)
        planAccountResponse = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: [enrolField])
        membershipPlanResponse = MembershipPlanModel(apiId: 5, status: nil, featureSet: featureSetResponse, images: nil, account: planAccountResponse, balances: nil, dynamicContent: nil, hasVouchers: true, card: nil)
        
        let burnModel = VoucherBurnModel(apiId: nil, currency: nil, prefix: "£", suffix: "gift", value: 500, type: "voucher")
        let stampsVoucherEarnModel = VoucherEarnModel(apiId: nil, currency: nil, prefix: "£", suffix: nil, type: .stamps, targetValue: 600, value: 500)
        voucherResponse = VoucherModel(apiId: nil, state: .inProgress, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: 1536080100, dateIssued: 3332020, expiryDate: 1535080100, earn: stampsVoucherEarnModel, burn: burnModel)
        
        mapResponseToManagedObject(Self.voucherResponse, managedObjectType: CD_Voucher.self) { voucher in
            self.voucher = voucher
        }
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        membershipCardBalanceModel = MembershipCardBalanceModel(apiId: nil, value: 500, currency: nil, prefix: "£", suffix: nil, updatedAt: nil)
        cardModel = CardModel(apiId: 300, barcode: "11111", membershipId: "1111", barcodeType: 1, colour: nil, secondaryColour: nil)
        membershipCardStatusModel = MembershipCardStatusModel(apiId: 300, state: .authorised, reasonCodes: nil)
        baseMembershipCardResponse = MembershipCardModel(apiId: 300, membershipPlan: 500, membershipTransactions: nil, status: membershipCardStatusModel, card: cardModel, images: nil, account: nil, paymentCards: nil, balances: [membershipCardBalanceModel], vouchers: [voucherResponse], openedTime: nil)
        
        mapResponseToManagedObject(baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
            self.mapMembershipPlan()
            self.membershipCard.membershipPlan = self.membershipPlan
        }
        
        //Current.wallet.launch()
        model = LoyaltyWalletViewModel()
    }
    
    override func setUp() {
        Current.wallet.updateMembershipPlans(membershipPlans: [Self.membershipPlan])
        Current.wallet.updateMembershipCards(membershipCards: [Self.membershipCard])
    }
    
    override func tearDown() {
        Current.wallet.setMembershipPlansToNil()
        Current.wallet.setMembershipCardsToNil()
    }
    
    private func mapMembershipCard() {
        mapResponseToManagedObject(Self.baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { card in
            Self.membershipCard = card
            Self.membershipCard.membershipPlan = Self.membershipPlan
        }
    }
    
    private class func mapMembershipPlan() {
        mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
        }
    }

    func test_hasValidCards() throws {
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for wallet setup")], timeout: 3.0)
        XCTAssertNotNil(Self.model.cards)
    }
    
    func test_hasWalletPrompts() throws {
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for wallet setup")], timeout: 3.0)
        Self.model.setupWalletPrompts()
        XCTAssertNotNil(Self.model.walletPrompts)
    }
    
    func test_toCardDetail_returnsCorrectVC() throws {
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for wallet setup")], timeout: 1.0)
        Self.model.toCardDetail(for: Self.membershipCard)
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: LoyaltyCardFullDetailsViewController.self))
        Current.navigate.close()
    }
    
    func test_alertShowsOnSortOrderChange() throws {
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for wallet setup")], timeout: 1.0)
        Self.model.showSortOrderChangeAlert(onCancel: {})
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: BinkAlertController.self))
    }
    
    func test_showsDeleteConfirmation() throws {
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for wallet setup")], timeout: 1.0)
        Self.model.showDeleteConfirmationAlert(card: Self.membershipCard, onCancel: {})
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: BinkAlertController.self))
    }
    
    func test_showsNoBarCodeAlert() throws {
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for wallet setup")], timeout: 1.0)
        Self.model.showNoBarcodeAlert(completion: {})
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: BinkAlertController.self))
    }
    
    func test_sortStateIsNewest() throws {
        Self.model.setMembershipCardsSortingType(sortType: .newest)
        let type = Self.model.getCurrentMembershipCardsSortType()?.rawValue
        
        XCTAssertEqual(type, "Newest")
    }
    
    func test_sortStateIsCustom() throws {
        Self.model.setMembershipCardsSortingType(sortType: .custom)
        let type = Self.model.getCurrentMembershipCardsSortType()?.rawValue
        
        XCTAssertEqual(type, "Custom")
    }
    
    func test_sortStateIsRecent() throws {
        Self.model.setMembershipCardsSortingType(sortType: .recent)
        let type = Self.model.getCurrentMembershipCardsSortType()?.rawValue
        
        XCTAssertEqual(type, "Recent")
    }
    
//    func test_shouldReturnLocalOrder() throws {
//        Current.userDefaults.set(["300"], forDefaultsKey: .localWalletOrder(userId: Current.userManager.currentUserId!, walletType: .loyalty))
//        let order = Self.model.getLocalWalletOrderFromUserDefaults()
//        XCTAssertTrue(!order!.isEmpty)
//    }
    
//    func test_localOrderShouldBeEmpty() throws {
//        Self.model.clearLocalWalletSortedCardsKey()
//        let order = Self.model.getLocalWalletOrderFromUserDefaults()
//        XCTAssertTrue(order!.isEmpty)
//    }
    
    func test_membershipCardHasMoved() throws {
        Self.model.setMembershipCardMoved(hasMoved: true)
        XCTAssertTrue(Self.model.hasMembershipCardMoved())
        
        Self.model.setMembershipCardMoved(hasMoved: false)
        XCTAssertTrue(!Self.model.hasMembershipCardMoved())
    }
}
