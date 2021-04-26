//
//  BinkModuleViewModelTests.swift
//  binkappTests
//
//  Created by Nick Farrant on 21/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class BinkModuleViewModelTests: XCTestCase, CoreDataTestable {
    private var sut: BinkModuleViewModel!
    
    private var baseFeatureSetModel: FeatureSetModel!
    private var baseMembershipPlanModel: MembershipPlanModel!
    private var baseMembershipCardModel: MembershipCardModel!
    private var basePaymentCardModel: PaymentCardModel!
    
    private var mappedMembershipCard: CD_MembershipCard!
    private var mappedPaymentCards: [CD_PaymentCard]!
    
    override func setUp() {
        super.setUp()
        
        sut = nil
        baseFeatureSetModel = nil
        baseMembershipPlanModel = nil
        baseMembershipCardModel = nil
        mappedMembershipCard = nil
        mappedPaymentCards = nil
        
        baseFeatureSetModel = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: true, cardType: .link, linkingSupport: nil, hasVouchers: nil)
        
        baseMembershipPlanModel = MembershipPlanModel(apiId: nil, status: nil, featureSet: baseFeatureSetModel, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        
        baseMembershipCardModel = MembershipCardModel(apiId: nil, membershipPlan: 1, membershipTransactions: nil, status: MembershipCardStatusModel(apiId: nil, state: .authorised, reasonCodes: nil), card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        
        basePaymentCardModel = PaymentCardModel(apiId: 1, membershipCards: nil, status: nil, card: nil, account: nil)
        mapResponseToManagedObject(basePaymentCardModel, managedObjectType: CD_PaymentCard.self) { mappedPaymentCard in
            self.mappedPaymentCards = [mappedPaymentCard]
        }
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedMembershipCard in
            self.mappedMembershipCard = mappedMembershipCard
        }
    }
    
    // MARK: Points module - Login unavailable
    
    func test_pointsModule_noTransactions_noPoints_stateReturnsCorrectly() {
        baseFeatureSetModel.hasPoints = false
        baseMembershipPlanModel.featureSet = baseFeatureSetModel
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .loginUnavailable)
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsInactive")
            XCTAssertEqual(self.sut.titleText, L10n.historyTitle)
            XCTAssertEqual(self.sut.subtitleText, L10n.notAvailableTitle)
        }
    }
    
    // MARK: Points module - PLR
    
    func test_pointsModule_plrWithTransactions_stateReturnsCorrectly() {
        baseFeatureSetModel.transactionsAvailable = true
        baseMembershipPlanModel.featureSet = baseFeatureSetModel
        baseMembershipPlanModel.hasVouchers = true
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .plrTransactions)
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsActive")
            XCTAssertEqual(self.sut.titleText, L10n.plrLcdPointsModuleAuthTitle)
            XCTAssertEqual(self.sut.subtitleText, L10n.pointsModuleViewHistoryMessage)
        }
    }
    
    func test_pointsModule_plrNoTransactions_stateReturnsCorrectly() {
        baseMembershipPlanModel.featureSet = baseFeatureSetModel
        baseMembershipPlanModel.hasVouchers = true
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .aboutMembership)
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsActive")
            XCTAssertEqual(self.sut.titleText, L10n.plrLcdPointsModuleTitle)
            XCTAssertEqual(self.sut.subtitleText, L10n.plrLcdPointsModuleDescription)
        }
    }
    
    // MARK: Points module - PLL
    
    func test_pointsModule_pllWithTransactions_stateReturnsCorrectly() {
        baseFeatureSetModel.transactionsAvailable = true
        baseMembershipPlanModel.featureSet = baseFeatureSetModel
        
        let balanceModel = MembershipCardBalanceModel(apiId: nil, value: 1.23, currency: nil, prefix: "£", suffix: "", updatedAt: nil)
        baseMembershipCardModel.balances = [balanceModel]
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .pllTransactions(transactionsAvailable: nil, formattedTitle: nil, lastChecked: nil))
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsActive")
            XCTAssertEqual(self.sut.titleText, "£1.23 ")
            XCTAssertEqual(self.sut.subtitleText, L10n.pointsModuleViewHistoryMessage)
        }
    }
    
    func test_pointsModule_pllNoTransactions_stateReturnsCorrectly() {
        let balanceModel = MembershipCardBalanceModel(apiId: nil, value: 1.23, currency: nil, prefix: "£", suffix: "", updatedAt: nil)
        baseMembershipCardModel.balances = [balanceModel]
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .pllTransactions(transactionsAvailable: nil, formattedTitle: nil, lastChecked: nil))
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsActive")
            XCTAssertEqual(self.sut.titleText, "£1.23 ")
            XCTAssertNotEqual(self.sut.subtitleText, L10n.pointsModuleViewHistoryMessage)
        }
    }
    
    // MARK: Points module - Pending
    
    func test_pointsModule_pending_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .pending, reasonCodes: nil)
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .pending)
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLoginPending")
            XCTAssertEqual(self.sut.titleText, L10n.pendingTitle)
            XCTAssertEqual(self.sut.subtitleText, L10n.pleaseWaitTitle)
        }
    }
    
    // MARK: Points module - Failed, unauthorised
    
    func test_pointsModule_failed_noReasonCode_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .failed, reasonCodes: nil)
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .noReasonCode)
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLogin")
            XCTAssertEqual(self.sut.titleText, L10n.errorTitle)
            XCTAssertEqual(self.sut.subtitleText, L10n.pleaseTryAgainTitle)
        }
    }
    
    func test_pointsModule_unauthorised_noReasonCode_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .unauthorised, reasonCodes: nil)
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .noReasonCode)
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLogin")
            XCTAssertEqual(self.sut.titleText, L10n.errorTitle)
            XCTAssertEqual(self.sut.subtitleText, L10n.pleaseTryAgainTitle)
        }
    }
    
    func test_pointsModule_failed_enrolmentDataRejectedByMerchant_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .failed, reasonCodes: [.enrolmentDataRejectedByMerchant])
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .signUp)
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLogin")
            XCTAssertEqual(self.sut.titleText, L10n.signUpFailedTitle)
            XCTAssertEqual(self.sut.subtitleText, L10n.pleaseTryAgainTitle)
        }
    }
    
    func test_pointsModule_unauthorised_enrolmentDataRejectedByMerchant_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .unauthorised, reasonCodes: [.enrolmentDataRejectedByMerchant])
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .signUp)
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLogin")
            XCTAssertEqual(self.sut.titleText, L10n.signUpFailedTitle)
            XCTAssertEqual(self.sut.subtitleText, L10n.pleaseTryAgainTitle)
        }
    }
    
    func test_pointsModule_failed_accountNotRegistered_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .failed, reasonCodes: [.accountNotRegistered])
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .patchGhostCard(type: .points(membershipCard: mappedCard)))
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLogin")
            XCTAssertEqual(self.sut.titleText, L10n.registerGcTitle)
            XCTAssertEqual(self.sut.subtitleText, L10n.pointsModuleToSeeHistory)
        }
    }
    
    func test_pointsModule_unauthorised_accountNotRegistered_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .unauthorised, reasonCodes: [.accountNotRegistered])
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .patchGhostCard(type: .points(membershipCard: mappedCard)))
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLogin")
            XCTAssertEqual(self.sut.titleText, L10n.registerGcTitle)
            XCTAssertEqual(self.sut.subtitleText, L10n.pointsModuleToSeeHistory)
        }
    }
    
    func test_pointsModule_failed_accountAlreadyExists_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .failed, reasonCodes: [.accountAlreadyExists])
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .loginChanges(type: .points(membershipCard: mappedCard), status: nil, reasonCode: nil))
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLogin")
            XCTAssertEqual(self.sut.titleText, L10n.pointsModuleAccountExistsStatus)
            XCTAssertEqual(self.sut.subtitleText, L10n.pointsModuleLogIn)
        }
    }
    
    func test_pointsModule_unauthorised_accountAlreadyExists_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .unauthorised, reasonCodes: [.accountAlreadyExists])
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.state, .loginChanges(type: .points(membershipCard: mappedCard), status: nil, reasonCode: nil))
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLogin")
            XCTAssertEqual(self.sut.titleText, L10n.pointsModuleAccountExistsStatus)
            XCTAssertEqual(self.sut.subtitleText, L10n.pointsModuleLogIn)
        }
    }
    
    // MARK: Link module - Unlinkable
    
    func test_linkModule_cardTypeStore_stateReturnsCorrectly() {
        baseFeatureSetModel.cardType = .store
        baseMembershipPlanModel.featureSet = baseFeatureSetModel
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .link(membershipCard: mappedCard, paymentCards: nil))
            
            XCTAssertEqual(self.sut.state, .unlinkable)
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsLinkInactive")
            XCTAssertEqual(self.sut.titleText, L10n.cardLinkingStatus)
            XCTAssertEqual(self.sut.subtitleText, L10n.notAvailableTitle)
        }
    }
    
    func test_linkModule_cardTypeView_stateReturnsCorrectly() {
        baseFeatureSetModel.cardType = .view
        baseMembershipPlanModel.featureSet = baseFeatureSetModel
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .link(membershipCard: mappedCard, paymentCards: nil))
            
            XCTAssertEqual(self.sut.state, .unlinkable)
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsLinkInactive")
            XCTAssertEqual(self.sut.titleText, L10n.cardLinkingStatus)
            XCTAssertEqual(self.sut.subtitleText, L10n.notAvailableTitle)
        }
    }
    
    // MARK: Link module - Authorised
    
    func test_linkModule_authorised_noPaymentCards_stateReturnsCorrectly() {
        mappedPaymentCards = []
        sut = BinkModuleViewModel(type: .link(membershipCard: mappedMembershipCard, paymentCards: mappedPaymentCards))
        
        XCTAssertEqual(sut.state, .pllNoPaymentCards)
        XCTAssertEqual(sut.imageName, "lcdModuleIconsLinkError")
        XCTAssertEqual(sut.titleText, L10n.cardLinkStatus)
        XCTAssertEqual(sut.subtitleText, L10n.linkModuleToPaymentCardsMessage)
    }
    
    func test_linkModule_authorised_paymentCards_noLinkedCards_stateReturnsCorrectly() {
        sut = BinkModuleViewModel(type: .link(membershipCard: mappedMembershipCard, paymentCards: mappedPaymentCards))
        
        XCTAssertEqual(sut.state, .pllError)
        XCTAssertEqual(sut.imageName, "lcdModuleIconsLinkError")
        XCTAssertEqual(sut.titleText, L10n.cardLinkStatus)
        XCTAssertEqual(sut.subtitleText, L10n.linkModuleToPaymentCardsMessage)
    }
    
    func test_linkModule_authorised_singlePaymentCard_singleLinkedCard_stateReturnsCorrectly() {
        let linkedCardResponse = LinkedCardResponse(id: 1, activeLink: true)
        baseMembershipCardModel.paymentCards = [linkedCardResponse]
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .link(membershipCard: mappedCard, paymentCards: self.mappedPaymentCards))
            
            XCTAssertEqual(self.sut.state, .pll(linkedPaymentCards: mappedCard.formattedLinkedPaymentCards, paymentCards: self.mappedPaymentCards))
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsLinkActive")
            XCTAssertEqual(self.sut.titleText, L10n.cardLinkedStatus)
            XCTAssertEqual(self.sut.subtitleText, L10n.linkModuleToNumberOfPaymentCardsMessage(1, 1))
        }
    }
    
    // MARK: Link module - Unauthorised
    
    func test_linkModule_unauthorised_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .unauthorised, reasonCodes: nil)
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .link(membershipCard: self.mappedMembershipCard, paymentCards: self.mappedPaymentCards))
            
            XCTAssertEqual(self.sut.state, .loginChanges(type: .points(membershipCard: mappedCard), status: nil, reasonCode: nil))
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLogin")
            XCTAssertEqual(self.sut.titleText, L10n.logInTitle)
            XCTAssertEqual(self.sut.subtitleText, L10n.linkModuleToLinkToCardsMessage)
        }
    }
    
    // MARK: Link module - Failed
    
    func test_linkModule_failed_noReasonCode_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .failed, reasonCodes: nil)
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .link(membershipCard: mappedCard, paymentCards: self.mappedPaymentCards))
            
            XCTAssertEqual(self.sut.state, .noReasonCode)
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLogin")
            XCTAssertEqual(self.sut.titleText, "error_title".localized)
            XCTAssertEqual(self.sut.subtitleText, "please_try_again_title".localized)
        }
    }
    
    func test_linkModule_failed_enrolmentDataRejectedByMerchant_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .failed, reasonCodes: [.enrolmentDataRejectedByMerchant])
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .link(membershipCard: mappedCard, paymentCards: self.mappedPaymentCards))
            
            XCTAssertEqual(self.sut.state, .signUp)
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLogin")
            XCTAssertEqual(self.sut.titleText, "sign_up_failed_title".localized)
            XCTAssertEqual(self.sut.subtitleText, "please_try_again_title".localized)
        }
    }
    
    func test_linkModule_failed_accountNotRegistered_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .failed, reasonCodes: [.accountNotRegistered])
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .link(membershipCard: mappedCard, paymentCards: self.mappedPaymentCards))
            
            XCTAssertEqual(self.sut.state, .patchGhostCard(type: .link(membershipCard: mappedCard, paymentCards: self.mappedPaymentCards)))
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLogin")
            XCTAssertEqual(self.sut.titleText, "register_gc_title".localized)
            XCTAssertEqual(self.sut.subtitleText, "please_try_again_title".localized)
        }
    }
    
    func test_linkModule_failed_defaultReasonCode_stateReturnsCorrectly() {
        baseMembershipCardModel.status = MembershipCardStatusModel(apiId: nil, state: .failed, reasonCodes: [.enrolmentInProgress])
        
        mapMembershipCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .link(membershipCard: mappedCard, paymentCards: self.mappedPaymentCards))
            
            XCTAssertEqual(self.sut.state, .loginChanges(type: .link(membershipCard: mappedCard, paymentCards: self.mappedPaymentCards), status: nil, reasonCode: nil))
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsLogin")
            XCTAssertEqual(self.sut.titleText, "log_in_failed_title".localized)
            XCTAssertEqual(self.sut.subtitleText, "please_try_again_title".localized)
        }
    }
    
    // MARK: Private methods
    
    private func mapMembershipCard(with planModel: MembershipPlanModel, completion: @escaping (CD_MembershipCard) -> Void) {
        mapResponseToManagedObject(planModel, managedObjectType: CD_MembershipPlan.self) { [weak self] mappedPlan in
            guard let self = self else { return }
            
            self.mapResponseToManagedObject(self.baseMembershipCardModel, managedObjectType: CD_MembershipCard.self) { mappedCard in
                mappedCard.membershipPlan = mappedPlan
                
                completion(mappedCard)
            }
        }
    }
}
