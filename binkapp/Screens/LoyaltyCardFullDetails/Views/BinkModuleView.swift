//
//  BinkModuleView.swift
//  binkapp
//
//  Created by Dorin Pop on 12/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol BinkModuleViewDelegate {
    func binkModuleViewWasTapped(_: BinkModuleView, withAction action: BinkModuleView.BinkModuleAction)
}

class BinkModuleView: CustomView {
    @IBOutlet private weak var moduleImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    enum ModuleType: Int {
        case points = 0
        case link
    }
    
    enum BinkModuleAction: Int {
        case login = 0
        case loginChanges
        case transactions
        case loginPending
        case loginUnavailable
        case signUp
        case signUpPending
        case registerGhostCard
        case registerGhostCardPending
        case pllEmpty
        case pll
        case unLinkable
        case genericError
    }
    
    private var action: BinkModuleAction?
    private var delegate: BinkModuleViewDelegate?
    
    func configure(moduleType:ModuleType, membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel, paymentCards: [PaymentCardModel]? = nil, delegate: BinkModuleViewDelegate) {
        self.delegate = delegate
        layer.shadowColor = UIColor.black.cgColor
        
        switch moduleType{
        case .points:
            configurePointsModule(membershipCard: membershipCard, membershipPlan: membershipPlan)
            break
        case .link:
            if let paymentCardsArray = paymentCards {
                configureLinkModule(membershipCard: membershipCard, membershipPlan: membershipPlan, paymentCards: paymentCardsArray)
            }
            break
        }
    }
    
    // MARK: - Actions
    
    @IBAction func pointsModuleTapepd(_ sender: Any) {
        if let binkModuleAction = action {
            delegate?.binkModuleViewWasTapped(self, withAction: binkModuleAction)
        }
    }
}

// MARK: - Private methods

private extension BinkModuleView {
    func configure(imageName: String, titleText: String, subtitleText: String, touchAction: BinkModuleAction) {
        moduleImageView.image = UIImage(named: imageName)
        titleLabel.text = titleText
        subtitleLabel.text = subtitleText
        action = touchAction
    }
    
    // Configure points module view
    func configurePointsModule(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel) {
        guard membershipPlan.featureSet?.hasPoints ?? false || membershipPlan.featureSet?.transactionsAvailable ?? false else {
            // Points module 1.5
            configure(imageName: "lcdModuleIconsPointsInactive", titleText: "history_title".localized, subtitleText: "not_available_title".localized, touchAction: .loginUnavailable)
            return
        }
        
        switch membershipCard.status?.state {
        case .authorised:
            // Points module 1.1, 1.2
            if let balances = membershipCard.balances, let value = balances[0].value {
                let titleText = (balances[0].prefix ?? "") + String(value) + " " + (balances[0].suffix ?? "")
                let subtitleText = (membershipPlan.featureSet?.transactionsAvailable ?? false) ? "points_module_view_history_message".localized : "points_module_last_checked".localized + (balances[0].updatedAt?.stringFromTimeInterval() ?? "")
                configure(imageName: "lcdModuleIconsPointsActive", titleText: titleText, subtitleText: subtitleText, touchAction: .transactions)
            }
            break
        case .unauthorised:
            // Points Module 1.3, 1.4
            configure(imageName: "lcdModuleIconsPointsLogin", titleText: "log_in_title".localized, subtitleText: "points_module_to_see_history".localized, touchAction: .login)
            break
        case .pending:
            let imageName = "lcdModuleIconsPointsLoginPending"
            if let reasonCodes = membershipCard.status?.reasonCodes, reasonCodes.count > 0 {
                switch reasonCodes[0] {
                case "X200":
                    // Points module 1.9
                    configure(imageName: imageName, titleText: "points_module_signing_up_status".localized, subtitleText: "please_wait_title".localized, touchAction: .signUpPending)
                    break
                case "X000", "X301":
                    // Points module 1.7
                    configure(imageName: imageName, titleText: "points_module_signing_up_status".localized, subtitleText: "please_wait_title".localized, touchAction: .loginPending)
                    break
                default:
                    // Points module 1.11 (need reason codes, set by defaul)
                    configure(imageName: imageName, titleText: "points_module_registering_card_status".localized, subtitleText: "please_wait_title".localized, touchAction: .registerGhostCardPending)
                    break
                }
            }
            break
        case .failed:
            let imageName = "lcdModuleIconsPointsLogin"
            if let reasonCodes = membershipCard.status?.reasonCodes, reasonCodes.count > 0 {
                switch reasonCodes[0] {
                case "X201":
                    // Points module 1.8
                    configure(imageName: imageName, titleText: "sign_up_failed_title".localized, subtitleText: "please_try_again_title".localized, touchAction: .signUp)
                    break
                case "X105", "X202":
                    // Points module 1.x (to be defined)
                    configure(imageName: imageName, titleText: "log_in_title".localized, subtitleText: "points_module_to_see_history".localized, touchAction: .loginChanges)
                    break
                case "X101", "X102", "X103", "X104", "X302", "X303", "X304":
                    // Points module 1.6
                    configure(imageName: imageName, titleText: "points_module_retry_log_in_status".localized, subtitleText: "points_module_to_see_history".localized, touchAction: .loginChanges)
                    break
                default:
                    // Points module 1.10 (need reason codes, set by default)
                    configure(imageName: imageName, titleText: "registration_failed_title".localized, subtitleText: "please_try_again_title".localized, touchAction: .registerGhostCard)
                    break
                }
            }
            break
        default:
            return
        }
    }
    
    // Configure link module view
    func configureLinkModule(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel, paymentCards: [PaymentCardModel]) {
        guard membershipPlan.featureSet?.cardType == FeatureSetModel.PlanCardType.link else {
            switch membershipPlan.featureSet?.cardType {
            case .store, .view:
                // Link module 2.8
                configure(imageName: "lcdModuleIconsLinkInactive", titleText: "card_link_status".localized, subtitleText: "not_available_title".localized, touchAction: .unLinkable)
                 break
            default:
                // Link module 2.4
                configure(imageName: "lcdModuleIconsLinkError", titleText: "link_module_error_title".localized, subtitleText: "error_title".localized, touchAction: .genericError)
                break
            }
            return
        }
        switch membershipCard.status?.state {
        case .authorised:
            let linkedCard = paymentCards.first(where: { $0.activeLink == true})
            guard membershipCard.paymentCards?.count ?? 0 == 0, linkedCard == nil else {
                // Link module 2.1
                let subtitleText = "To " + String(membershipCard.paymentCards?.count ?? 0) + " of " + String(paymentCards.count) + " cards"
                configure(imageName: "lcdModuleIconsLinkActive", titleText: "card_link_status".localized, subtitleText: subtitleText, touchAction: .pll)
                return
            }
            if paymentCards.count == 0 {
                // Link module 2.2
                configure(imageName: "lcdModuleIconsLinkError", titleText: "card_link_status".localized, subtitleText: "link_module_to_payment_cards_message".localized, touchAction: .pllEmpty)
            } else {
                // Link module 2.3
                configure(imageName: "lcdModuleIconsLinkError", titleText: "card_link_status".localized, subtitleText: "link_module_to_payment_cards_message".localized, touchAction: .pll)
            }
            break
        case .unauthorised:
            // Link module 2.5
            configure(imageName: "lcdModuleIconsPointsLogin", titleText: "log_in_title".localized, subtitleText: "link_module_to_link_to_cards_message".localized, touchAction: .loginChanges)
            break
        case .pending:
            // Link moduel 2.6
            configure(imageName: "lcdModuleIconsPointsLoginPending", titleText: "pending_title".localized, subtitleText: "please_wait_title".localized, touchAction: .loginPending)
            break
        case .failed:
            // Link module 2.7
            configure(imageName: "lcdModuleIconsPointsLogin", titleText: "log_in_failed_title".localized, subtitleText: "please_try_again_title".localized, touchAction: .loginChanges)
            break
        default:
            return
        }
    }
}
