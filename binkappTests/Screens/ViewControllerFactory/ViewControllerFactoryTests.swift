//
//  ViewControllerFactoryTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 22/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
import CardScan
import SwiftUI
@testable import binkapp

// swiftlint:disable all

class ViewControllerFactoryTests: XCTestCase, CoreDataTestable {
    static var membershipCard: CD_MembershipCard!
    static var baseMembershipCardResponse: MembershipCardModel!
    static var membershipPlanResponse: MembershipPlanModel!
    static var membershipPlan: CD_MembershipPlan!
    static var featureSetResponse: FeatureSetModel!
    static var planAccountResponse: MembershipPlanAccountModel!
    static var voucherResponse: VoucherModel!
    static var voucher: CD_Voucher!
    
    override class func setUp() {
        super.setUp()
        
        baseMembershipCardResponse = MembershipCardModel(apiId: 300, membershipPlan: 500, membershipTransactions: nil, status: nil, card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        
        mapResponseToManagedObject(baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
        }
        
        featureSetResponse = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil)
        let enrolField = EnrolFieldModel(apiId: nil, column: nil, validation: nil, fieldDescription: nil, type: nil, choices: [], commonName: nil)
        planAccountResponse = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Harvey Nichols", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: [enrolField])
        
        membershipPlanResponse = MembershipPlanModel(apiId: 5, status: nil, featureSet: featureSetResponse, images: nil, account: planAccountResponse, balances: nil, dynamicContent: nil, hasVouchers: false, card: nil)
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        let burnModel = VoucherBurnModel(apiId: nil, currency: nil, prefix: "£", suffix: "gift", value: 500, type: "voucher")
        let stampsVoucherEarnModel = VoucherEarnModel(apiId: nil, currency: nil, prefix: nil, suffix: nil, type: .stamps, targetValue: nil, value: nil)
        voucherResponse = VoucherModel(apiId: nil, state: .issued, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: 1536080100, dateIssued: 3332020, expiryDate: 1535080100, earn: stampsVoucherEarnModel, burn: burnModel)
        
        mapResponseToManagedObject(Self.voucherResponse, managedObjectType: CD_Voucher.self) { voucher in
            Self.voucher = voucher
        }
    }

    func test_makeLoyaltyScannerViewController_navigatesToCorrectViewController() {
        let vc = ViewControllerFactory.makeLoyaltyScannerViewController(delegate: nil)
        XCTAssertTrue(vc.isKind(of: BarcodeScannerViewController.self))
    }
    
    func test_makeBrowseBrandsViewController_navigatesToCorrectViewController() {
        let vc = ViewControllerFactory.makeBrowseBrandsViewController()
        XCTAssertTrue(vc.isKind(of: BrowseBrandsViewController.self))
    }
    
    func test_makePaymentCardScannerViewController_navigatesToCorrectViewController() {
        let vc = ViewControllerFactory.makePaymentCardScannerViewController(strings: PaymentCardScannerStrings(), delegate: nil)
        XCTAssertTrue(vc!.isKind(of: ScanViewController.self))
    }
    
    func test_makeAddPaymentCardViewController_navigatesToCorrectViewController() {
        let vc = ViewControllerFactory.makeAddPaymentCardViewController(journey: .wallet)
        XCTAssertTrue(vc.isKind(of: AddPaymentCardViewController.self))
    }
    
    func test_makeAddOrJoinViewController_navigatesToCorrectViewController() {
        let vc = ViewControllerFactory.makeAddOrJoinViewController(membershipPlan: Self.membershipPlan)
        XCTAssertTrue(vc.isKind(of: AddOrJoinViewController.self))
    }
    
    func test_makePaymentTermsAndConditionsViewController_navigatesToCorrectViewController() {
        let configurationModel = ReusableModalConfiguration(title: L10n.termsAndConditionsTitle, text: NSMutableAttributedString(), primaryButtonTitle: L10n.iAccept, primaryButtonAction: nil, secondaryButtonTitle: L10n.iDecline, secondaryButtonAction: nil)
        let vc = ViewControllerFactory.makePaymentTermsAndConditionsViewController(configurationModel: configurationModel)
        XCTAssertTrue(vc.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_makePllViewController_navigatesToCorrectViewController() {
        let vc = ViewControllerFactory.makePllViewController(membershipCard: Self.membershipCard, journey: .existingCard)
        XCTAssertTrue(vc.isKind(of: PLLScreenViewController.self))
    }
    
    func test_makePatchGhostCardViewController_navigatesToCorrectViewController() {
        let vc = ViewControllerFactory.makePatchGhostCardViewController(membershipPlan: Self.membershipPlan)
        XCTAssertTrue(vc.isKind(of: AuthAndAddViewController.self))
    }
    
    func test_makeSignUpViewController_navigatesToCorrectViewController() {
        let vc = ViewControllerFactory.makeSignUpViewController(membershipPlan: Self.membershipPlan)
        XCTAssertTrue(vc.isKind(of: AuthAndAddViewController.self))
    }
    
    func test_makeLoyaltyCardDetailViewController_navigatesToCorrectViewController() {
        let vc = ViewControllerFactory.makeLoyaltyCardDetailViewController(membershipCard: Self.membershipCard)
        XCTAssertTrue(vc.isKind(of: LoyaltyCardFullDetailsViewController.self))
    }
    
    func test_makeBarcodeViewController_navigatesToCorrectViewController() {
        let vc = ViewControllerFactory.makeBarcodeViewController(membershipCard: Self.membershipCard)
        XCTAssertTrue(vc.isKind(of: UIHostingController<BarcodeScreenSwiftUIView>.self))
    }
    
    func test_makeVoucherDetailViewController_navigatesToCorrectViewController() {
        let vc = ViewControllerFactory.makeVoucherDetailViewController(voucher: Self.voucher, plan: Self.membershipPlan)
        XCTAssertTrue(vc.isKind(of: PLRRewardDetailViewController.self))
    }
    
    func test_makeReusableTemplateViewController_navigatesToCorrectViewController() {
        let configurationModel = ReusableModalConfiguration(title: L10n.termsAndConditionsTitle, text: NSMutableAttributedString(), primaryButtonTitle: L10n.iAccept, primaryButtonAction: nil, secondaryButtonTitle: L10n.iDecline, secondaryButtonAction: nil)
        let vc = ViewControllerFactory.makeReusableTemplateViewController(configuration: configurationModel)
        XCTAssertTrue(vc.isKind(of: ReusableTemplateViewController.self))
    }
}