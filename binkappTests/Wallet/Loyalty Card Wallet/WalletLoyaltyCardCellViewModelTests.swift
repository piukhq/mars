//
//  WalletLoyaltyCardCellViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 26/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp
// swiftlint:disable all

final class WalletLoyaltyCardCellViewModelTests: XCTestCase, CoreDataTestable {

    static var membershipPlan: CD_MembershipPlan!
    static var membershipPlanResponse: MembershipPlanModel!
    static var membershipPlanAccountModel: MembershipPlanAccountModel!
    
    static var membershipCardResponse: MembershipCardModel!
    
    static var membershipCardBalanceModel: MembershipCardBalanceModel!
    
    static var membershipCardStatusModel: MembershipCardStatusModel!
    
    static var featureSetModel: FeatureSetModel!
    
    static var cardResponse: CardModel!
    
    static var membershipCard: CD_MembershipCard!
    
    static var voucherResponse: VoucherModel!
    static var voucher: CD_Voucher!
    
    static var sut: WalletLoyaltyCardCellViewModel!
    
    override class func setUp() {
        super.setUp()
        
        let burnModel = VoucherBurnModel(apiId: 500, currency: nil, prefix: "£", suffix: "gift", value: 500, type: "voucher")
        let stampsVoucherEarnModel = VoucherEarnModel(apiId: 500, currency: nil, prefix: "£", suffix: "gift", type: .accumulator, targetValue: 600, value: 500)
        voucherResponse = VoucherModel(apiId: 500, state: .inProgress, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: 1536080100, dateIssued: 3332020, expiryDate: 1535080100, earn: stampsVoucherEarnModel, burn: burnModel)
        
        cardResponse = CardModel(apiId: nil, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: "#0000ff", secondaryColour: nil, merchantName: nil)
        
        featureSetModel = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: true, cardType: .link, linkingSupport: [.add], hasVouchers: false)
        
        membershipPlanAccountModel = MembershipPlanAccountModel(apiId: nil, planName: "Test Plan", planNameCard: nil, planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        
        membershipPlanResponse = MembershipPlanModel(apiId: 500, status: nil, featureSet: featureSetModel, images: nil, account: membershipPlanAccountModel, balances: nil, dynamicContent: nil, hasVouchers: true, card: cardResponse)
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        membershipCardBalanceModel = MembershipCardBalanceModel(apiId: nil, value: 500, currency: nil, prefix: "£", suffix: nil, updatedAt: nil)
        
        membershipCardStatusModel = MembershipCardStatusModel(apiId: 500, state: .authorised, reasonCodes: [.pointsScrapingLoginRequired])
        
        membershipCardResponse = MembershipCardModel(apiId: 300, membershipPlan: 500, membershipTransactions: nil, status: membershipCardStatusModel, card: cardResponse, images: nil, account: nil, paymentCards: nil, balances: [membershipCardBalanceModel], vouchers: [voucherResponse], openedTime: nil)
        
        mapResponseToManagedObject(membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
        }
        
        sut = WalletLoyaltyCardCellViewModel(membershipCard: membershipCard)
    }
    
    func test_shouldBeSetupCorrectly() throws {
        Self.membershipPlanResponse.featureSet?.cardType = .link
        
        mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
        }
        Self.membershipCardStatusModel.state = .authorised
        Self.membershipCardResponse.status = Self.membershipCardStatusModel
        
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
        
        XCTAssertNotNil(Self.sut.membershipPlan)
        
        XCTAssertNotNil(Self.sut.cardStatus)
        
        XCTAssertTrue(Self.sut.cardStatus == .authorised)
        
        XCTAssertNotNil(Self.sut.balance)
        
        XCTAssertTrue(Self.sut.balanceValue == 500)
        
        XCTAssertTrue(Self.sut.planHasPoints == true)
        
        XCTAssertTrue(Self.sut.planCardType == .link)
    }
    
    func test_shouldShowRetryStatus() throws {
        Self.membershipPlanResponse.featureSet?.cardType = .link
        
        mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
        }
        
        Self.membershipCardStatusModel.state = .failed
        Self.membershipCardResponse.status = Self.membershipCardStatusModel
        
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
        
        Self.sut = WalletLoyaltyCardCellViewModel(membershipCard: Self.membershipCard)
        
        XCTAssertTrue(Self.sut.shouldShowRetryStatus)
    }
    
    func test_shouldShowPointsValueLabel() throws {
        Self.membershipPlanResponse.featureSet?.cardType = .link
        
        mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
        }
        
        Self.membershipCardStatusModel.state = .failed
        Self.membershipCardResponse.status = Self.membershipCardStatusModel
        
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
        
        Self.sut = WalletLoyaltyCardCellViewModel(membershipCard: Self.membershipCard)
        
        XCTAssertTrue(Self.sut.shouldShowPointsValueLabel)
    }
    
    func test_shouldShowPointsSuffixLabel() throws {
        Self.membershipCardStatusModel.reasonCodes = nil
        Self.membershipCardStatusModel.state = .authorised
        
        Self.membershipCardResponse.status = Self.membershipCardStatusModel
        
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
        
        Self.sut = WalletLoyaltyCardCellViewModel(membershipCard: Self.membershipCard)
        XCTAssertTrue(Self.sut.shouldShowPointsSuffixLabel)
    }
    
    func test_shouldShowLinkStatus() throws {
        Self.membershipPlanResponse.featureSet?.cardType = .link
        
        mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
        }
        
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
        
        XCTAssertTrue(Self.sut.shouldShowLinkStatus)
    }
    
    func test_shouldShowLinkImage() throws {
        Self.membershipPlanResponse.featureSet?.cardType = .link
        
        mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
        }
        
        Self.membershipCardStatusModel.reasonCodes = nil
        Self.membershipCardStatusModel.state = .authorised
        
        Self.membershipCardResponse.status = Self.membershipCardStatusModel
        
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
        
        Self.sut = WalletLoyaltyCardCellViewModel(membershipCard: Self.membershipCard)
        
        XCTAssertTrue(Self.sut.shouldShowLinkImage)
    }
    
    func test_brandColorHex_shouldNotBeNil() throws {
        XCTAssertNotNil(Self.sut.brandColorHex)
    }
    
    func test_companyName_shouldNotBeNil() throws {
        XCTAssertNotNil(Self.sut.companyName)
    }
    
    func test_pointsValueText() throws {
        Self.membershipPlanResponse.featureSet?.cardType = .store
        
        mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
        }
        
        Self.membershipCardStatusModel.reasonCodes = nil
        Self.membershipCardStatusModel.state = .failed
        
        Self.membershipCardResponse.status = Self.membershipCardStatusModel
        
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
        
        Self.sut = WalletLoyaltyCardCellViewModel(membershipCard: Self.membershipCard)
        
        XCTAssertTrue(Self.sut.pointsValueText == "£500")
    }
    
    func test_pointsValueText_reasonCode_pointsScrapingLoginRequired() throws {
        Self.membershipCardStatusModel.reasonCodes = [.pointsScrapingLoginRequired]
        
        Self.membershipCardResponse.status = Self.membershipCardStatusModel
        
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
        
        Self.sut = WalletLoyaltyCardCellViewModel(membershipCard: Self.membershipCard)
        
        
        XCTAssertTrue(Self.sut.pointsValueText == L10n.loginTitle)
    }
    
    func test_pointsValueText_shouldShowRetryStatus() throws {
        Self.membershipCardStatusModel.reasonCodes = nil
        Self.membershipCardStatusModel.state = .failed
        
        Self.membershipCardResponse.status = Self.membershipCardStatusModel
        
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
        
        Self.sut = WalletLoyaltyCardCellViewModel(membershipCard: Self.membershipCard)
        
        
        XCTAssertTrue(Self.sut.pointsValueText == L10n.retryTitle)
    }
    
    func test_pointsValueText_plr_authorised() throws {
        Self.membershipCardStatusModel.reasonCodes = nil
        Self.membershipCardStatusModel.state = .authorised
        
        Self.membershipCardResponse.status = Self.membershipCardStatusModel
        
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
        
        Self.sut = WalletLoyaltyCardCellViewModel(membershipCard: Self.membershipCard)
        
        
        XCTAssertTrue(Self.sut.pointsValueText == "£500/£600 gift")
    }
    
    func test_pointsValueSuffixText_voucher_accumulator() throws {
        Self.membershipCardStatusModel.reasonCodes = nil
        Self.membershipCardStatusModel.state = .authorised
        
        Self.membershipCardResponse.status = Self.membershipCardStatusModel
        Self.membershipCardResponse.vouchers![0].earn?.type = .accumulator
        
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
        
        Self.sut = WalletLoyaltyCardCellViewModel(membershipCard: Self.membershipCard)
        
        
        XCTAssertTrue(Self.sut.pointsValueSuffixText == L10n.plrLoyaltyCardSubtitleAccumulator)
    }
    
    func test_pointsValueSuffixText_voucher_stamps() throws {
        Self.membershipCardStatusModel.reasonCodes = nil
        Self.membershipCardStatusModel.state = .authorised
        
        Self.membershipCardResponse.status = Self.membershipCardStatusModel
        Self.membershipCardResponse.vouchers![0].earn?.type = .stamps
        
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
        
        Self.sut = WalletLoyaltyCardCellViewModel(membershipCard: Self.membershipCard)
        
        
        XCTAssertTrue(Self.sut.pointsValueSuffixText == L10n.plrLoyaltyCardSubtitleStamps)
    }
}
