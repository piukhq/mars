//
//  LoyaltyCardFullDetailsViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 22/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
import SwiftUI
@testable import binkapp

// swiftlint:disable all
 
class LoyaltyCardFullDetailsViewModelTests: XCTestCase, CoreDataTestable {
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
    
    static var model: LoyaltyCardFullDetailsViewModel!
    
    var currentViewController: UIViewController {
        return Current.navigate.currentViewController!
    }
    
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
        baseMembershipCardResponse = MembershipCardModel(apiId: 300, membershipPlan: 500, membershipTransactions: nil, status: membershipCardStatusModel, card: cardModel, images: nil, account: nil, paymentCards: nil, balances: [membershipCardBalanceModel], vouchers: [voucherResponse])
        
        mapResponseToManagedObject(baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
<<<<<<< HEAD
=======
            self.mapMembershipPlan()
            self.membershipCard.membershipPlan = self.membershipPlan
>>>>>>> develop
        }
        
        let factory = WalletCardDetailInformationRowFactory()
        model = LoyaltyCardFullDetailsViewModel(membershipCard: membershipCard, informationRowFactory: factory)
    }
    
    private func mapMembershipCard() {
        mapResponseToManagedObject(Self.baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { card in
            Self.membershipCard = card
        }
    }
    
<<<<<<< HEAD
    private func mapMembershipPlan() {
=======
    private class func mapMembershipPlan() {
>>>>>>> develop
        mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
        }
    }
    
    func test_isMembershipCardAuthorised() throws {
        Self.baseMembershipCardResponse.status?.state = .authorised
        mapMembershipCard()
        XCTAssertTrue(Self.model.isMembershipCardAuthorised)
    }
    
    func test_isMembershipCardPLL() throws {
        Self.model.membershipCard.membershipPlan = Self.membershipPlan
        XCTAssertTrue(Self.model.isMembershipCardPLL)
    }
    
    func test_brandName() throws {
        Self.model.membershipCard.membershipPlan = Self.membershipPlan
        XCTAssertEqual(Self.model.brandName, "Tesco")
    }
    
<<<<<<< HEAD
=======
    func test_brandNameForGeoData() throws {
        Self.model.membershipCard.membershipPlan = Self.membershipPlan
        XCTAssertEqual(Self.model.brandNameForGeoData, "tesco")
    }
    
>>>>>>> develop
    func test_pointsValueText() throws {
        Self.baseMembershipCardResponse.status?.state = .failed
        mapMembershipCard()
        Self.model.membershipCard.membershipPlan = Self.membershipPlan
        XCTAssertNil(Self.model.pointsValueText)
    }
    
    func test_pointsValueText_isPLR() throws {
        Self.featureSetResponse = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: true)
        Self.membershipPlanResponse.hasVouchers = true
        Self.membershipPlanResponse.featureSet = Self.featureSetResponse
<<<<<<< HEAD
        mapMembershipPlan()
=======
        Self.mapMembershipPlan()
>>>>>>> develop
        Self.baseMembershipCardResponse.status?.state = .authorised
        mapMembershipCard()
        Self.model.membershipCard.membershipPlan = Self.membershipPlan
        XCTAssertEqual(Self.model.pointsValueText, "£500/£600")
    }
    
    func test_pointsValueText_balances() throws {
        Self.featureSetResponse = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: false)
        Self.membershipPlanResponse.hasVouchers = false
        Self.membershipPlanResponse.featureSet = Self.featureSetResponse
<<<<<<< HEAD
        mapMembershipPlan()
=======
        Self.mapMembershipPlan()
>>>>>>> develop

        Self.baseMembershipCardResponse.status?.state = .authorised
        mapMembershipCard()
        Self.model.membershipCard.membershipPlan = Self.membershipPlan
        XCTAssertEqual(Self.model.pointsValueText, "£500 ")
    }
    
    func test_aspectRatioWhenLink() throws {
        Self.model.membershipCard.membershipPlan = Self.membershipPlan
        XCTAssertEqual(Self.model.brandHeaderAspectRatio, 25 / 41)
    }
    
    func test_hasSecondaryColor() throws {
        Self.model.membershipCard.membershipPlan = Self.membershipPlan
        XCTAssertNotNil(Self.model.secondaryColor)
    }
    
    func test_shouldShowBarcodeButton() throws {
        Self.model.membershipCard.membershipPlan = Self.membershipPlan
        XCTAssertTrue(Self.model.shouldShowBarcodeButton)
    }
    
    func test_shouldShowBarCode() throws {
        Self.model.membershipCard.membershipPlan = Self.membershipPlan
        XCTAssertTrue(Self.model.shouldShowBarcode == false)
    }
    
    func test_toBarcodeModel_shouldnavigateToCorrectVC() throws {
        Self.model.toBarcodeModel()
        XCTAssertTrue(currentViewController.isKind(of: UIHostingController<BarcodeScreenSwiftUIView>.self))
    }
    
    func test_toGeoLocations_shouldnavigateToCorrectVC() throws {
        Self.model.toGeoLocations()
        XCTAssertTrue(currentViewController.isKind(of: GeoLocationsViewController.self))
    }
    
    func test_goToScreenForState_loginChanges_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.loginChanges(type: .points(membershipCard: Self.membershipCard), status: nil, reasonCode: nil))
        XCTAssertTrue(currentViewController.isKind(of: AuthAndAddViewController.self))
    }
    
    func test_goToScreenForState_lpcLoginRequired_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.lpcLoginRequired)
        XCTAssertTrue(currentViewController.isKind(of: AuthAndAddViewController.self))
    }
    
    func test_goToScreenForState_plrTransactions_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.plrTransactions)
        XCTAssertTrue(currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_goToScreenForState_pllTransactions_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.pllTransactions(transactionsAvailable: nil, formattedTitle: nil, lastChecked: nil))
        XCTAssertTrue(currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_goToScreenForState_pending_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.pending)
        XCTAssertTrue(currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_goToScreenForState_loginUnavailable_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.loginUnavailable)
        XCTAssertTrue(currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_goToScreenForState_signUp_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.signUp)
        XCTAssertTrue(currentViewController.isKind(of: AuthAndAddViewController.self))
    }
    
    func test_goToScreenForState_patchGhostCard_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.patchGhostCard(type: .points(membershipCard: Self.membershipCard)))
        XCTAssertTrue(currentViewController.isKind(of: AuthAndAddViewController.self))
    }
    
    func test_goToScreenForState_pllError_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.pllError)
        XCTAssertTrue(currentViewController.isKind(of: PLLScreenViewController.self))
    }
    
    func test_goToScreenForState_pllNoPaymentCards_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.pllNoPaymentCards)
        XCTAssertTrue(currentViewController.isKind(of: PLLScreenViewController.self))
    }
    
    func test_goToScreenForState_unlinkable_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.unlinkable)
        XCTAssertTrue(currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_goToScreenForState_genericError_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.genericError)
        XCTAssertTrue(currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_goToScreenForState_aboutMembership_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.aboutMembership)
        XCTAssertTrue(currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_goToScreenForState_noReasonCode_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.noReasonCode)
        XCTAssertTrue(currentViewController.isKind(of: AddOrJoinViewController.self))
    }
    
    func test_goToScreenForState_lpcBalance_shouldnavigateToCorrectVC() throws {
        Self.model.goToScreenForState(state: ModuleState.lpcBalance(formattedTitle: "", lastCheckedDate: Date()))
        XCTAssertTrue(currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_goToScreenForState_toRewardsHistoryScreen_shouldnavigateToCorrectVC() throws {
        Self.model.toRewardsHistoryScreen()
        XCTAssertTrue(currentViewController.isKind(of: PLRRewardsHistoryViewController.self))
    }
    
    func test_goToScreenForState_toAboutMembershipPlanScreen_shouldnavigateToCorrectVC() throws {
        Self.model.toAboutMembershipPlanScreen()
        XCTAssertTrue(currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_goToScreenForState_toSecurityAndPrivacyScreen_shouldnavigateToCorrectVC() throws {
        Self.model.toSecurityAndPrivacyScreen()
        XCTAssertTrue(currentViewController.isKind(of: UIHostingController<ReusableTemplateView>.self))
    }
    
    func test_goToScreenForState_toVoucherDetailScreen_shouldnavigateToCorrectVC() throws {
        Self.model.toVoucherDetailScreen(voucher: Self.voucher)
        XCTAssertTrue(currentViewController.isKind(of: PLRRewardDetailViewController.self))
    }
}
