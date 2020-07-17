//
//  BinkModuleView.swift
//  binkapp
//
//  Created by Dorin Pop on 12/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol BinkModuleViewDelegate: class {
    func binkModuleViewWasTapped(moduleView: BinkModuleView, withAction action: BinkModuleView.BinkModuleAction)
}

class BinkModuleView: CustomView {
    @IBOutlet private weak var moduleImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    enum ModuleType: Int {
        case points
        case link
    }
    
    enum BinkModuleAction: Int {
        case login
        case loginChanges
        case transactions
        case pending
        case loginUnavailable
        case signUp
        case patchGhostCard
        case registerGhostCard
        case pllEmpty
        case pll
        case unLinkable
        case genericError
        case aboutMembership
        case noReasonCode
    }
    
    private var action: BinkModuleAction?
    private weak var delegate: BinkModuleViewDelegate?
    
    func configure(moduleType: ModuleType, membershipCard: CD_MembershipCard, paymentCards: [CD_PaymentCard]? = nil, delegate: BinkModuleViewDelegate? = nil) {
        self.delegate = delegate

        switch moduleType{
        case .points:
            configurePointsModule(membershipCard: membershipCard)
            break
        case .link:
            if let paymentCardsArray = paymentCards {
                configureLinkModule(membershipCard: membershipCard, paymentCards: paymentCardsArray)
            }
            break
        }

        layer.applyDefaultBinkShadow()
    }
    
    // MARK: - Actions
    
    @IBAction func pointsModuleTappedd(_ sender: Any) {
        if let binkModuleAction = action {
            delegate?.binkModuleViewWasTapped(moduleView: self, withAction: binkModuleAction)
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
    func configurePointsModule(membershipCard: CD_MembershipCard) {
        guard let plan = membershipCard.membershipPlan,
            plan.featureSet?.hasPoints?.boolValue ?? false || plan.featureSet?.transactionsAvailable?.boolValue ?? false else {
            // Points module 1.5
            configure(imageName: "lcdModuleIconsPointsInactive", titleText: "history_title".localized, subtitleText: "not_available_title".localized, touchAction: .loginUnavailable)
            return
        }
        
        switch membershipCard.status?.status {
        case .authorised:
            // PLR
            if membershipCard.membershipPlan?.isPLR == true {
                configure(imageName: "lcdModuleIconsPointsActive", titleText: "plr_lcd_points_module_title".localized, subtitleText: "plr_lcd_points_module_description".localized, touchAction: .aboutMembership)
                break
            }

            // Points module 1.1, 1.2
            if let balances = membershipCard.balances.allObjects as? [CD_MembershipCardBalance],
                let balance = balances.first,
                let value = balance.value {
                                
                var titleText: String
                let prefix = balance.prefix ?? ""
                let suffix = balance.suffix ?? ""
                
                let floatBalanceValue = balance.value?.floatValue ?? 0
                
                if floatBalanceValue.hasDecimals {
                    titleText = prefix + String(format: "%.02f", floatBalanceValue) + " " + suffix
                } else {
                    titleText = prefix + "\(value.intValue)" + " " + suffix
                }
                
                let transactionsAvailable = plan.featureSet?.transactionsAvailable?.boolValue == true
                let date = Date(timeIntervalSince1970: balance.updatedAt?.doubleValue ?? 0)
                let subtitleText = (transactionsAvailable) ? "points_module_view_history_message".localized :
                    "points_module_last_checked".localized + " " + (date.timeAgoString(short: true) ?? "")
                configure(imageName: "lcdModuleIconsPointsActive", titleText: titleText, subtitleText: subtitleText, touchAction: .transactions)
            } else {
                configure(imageName: "lcdModuleIconsPointsLoginPending", titleText: "pending_title".localized, subtitleText: "please_wait_title".localized, touchAction: .pending)
            }
            break
        case .pending:
            let imageName = "lcdModuleIconsPointsLoginPending"
            configure(imageName: imageName, titleText: "pending_title".localized, subtitleText: "please_wait_title".localized, touchAction: .pending)
            break
        case .failed, .unauthorised:
            let imageName = "lcdModuleIconsPointsLogin"
            if let reasonCode = membershipCard.status?.formattedReasonCodes?.first {
                switch reasonCode {
                case .enrolmentDataRejectedByMerchant:
                    // Points module 1.8
                    configure(imageName: imageName, titleText: "sign_up_failed_title".localized, subtitleText: "please_try_again_title".localized, touchAction: .signUp)
                    break
                case .accountNotRegistered:
                     // Points module 1.x (to be defined)
                     configure(imageName: imageName, titleText: "register_gc_title".localized, subtitleText: "points_module_to_see_history".localized, touchAction: .patchGhostCard)
                    break
                case .accountAlreadyExists:
                    // Points module 1.12
                    configure(imageName: imageName, titleText: "points_module_account_exists_status".localized, subtitleText: "points_module_log_in".localized, touchAction: .loginChanges)
                    break
                case .accountDoesNotExist, .addDataRejectedByMerchant, .noAuthorizationProvided, .updateFailed, .noAuthorizationRequired, .authorizationDataRejectedByMerchant, .authorizationExpired, .pointsScrapingLoginFailed:
                    // Points module 1.6
                    configure(imageName: imageName, titleText: "points_module_retry_log_in_status".localized, subtitleText: "points_module_to_see_history".localized, touchAction: .loginChanges)
                    break
                default:
                    // Points module 1.10 (need reason codes, set by default)
                    configure(imageName: imageName, titleText: "registration_failed_title".localized, subtitleText: "please_try_again_title".localized, touchAction: .registerGhostCard)
                    break
                }
            }
            else {
                configure(imageName: imageName, titleText: "error_title".localized, subtitleText: "please_try_again_title".localized, touchAction: .noReasonCode)
            }
            break
        default:
            return
        }
    }
    
    // Configure link module view
    func configureLinkModule(membershipCard: CD_MembershipCard, paymentCards: [CD_PaymentCard]) {
        guard let plan = membershipCard.membershipPlan else { return }
        
        guard plan.featureSet?.planCardType == .link else {
            switch plan.featureSet?.planCardType {
            case .store, .view:
                // Link module 2.8
                configure(imageName: "lcdModuleIconsLinkInactive", titleText: "card_linking_status".localized, subtitleText: "not_available_title".localized, touchAction: .unLinkable)
                 break
            default:
                // Link module 2.4
                configure(imageName: "lcdModuleIconsLinkError", titleText: "link_module_error_title".localized, subtitleText: "error_title".localized, touchAction: .genericError)
                break
            }
            return
        }
        switch membershipCard.status?.status {
        case .authorised:
            let possiblyLinkedCard = paymentCards.first(where: { $0.linkedMembershipCards.count > 0})
            guard membershipCard.linkedPaymentCards.count == 0, !membershipCard.linkedPaymentCards.contains(possiblyLinkedCard as Any) else {
                // Link module 2.1
                let subtitleText = String(format: paymentCards.count == 1 ? "link_module_to_number_of_payment_card_message".localized : "link_module_to_number_of_payment_cards_message".localized, membershipCard.linkedPaymentCards.count, paymentCards.count)
                configure(imageName: "lcdModuleIconsLinkActive", titleText: "card_linked_status".localized, subtitleText: subtitleText, touchAction: .pll)
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
            configure(imageName: "lcdModuleIconsPointsLoginPending", titleText: "pending_title".localized, subtitleText: "please_wait_title".localized, touchAction: .pending)
            break
        case .failed:
            
            if let reasonCode = membershipCard.status?.formattedReasonCodes?.first {
                switch reasonCode {
                case .enrolmentDataRejectedByMerchant:
                    configure(imageName: "lcdModuleIconsPointsLogin", titleText: "sign_up_failed_title".localized, subtitleText: "please_try_again_title".localized, touchAction: .signUp)
                case .accountNotRegistered:
                    configure(imageName: "lcdModuleIconsPointsLogin", titleText: "register_gc_title".localized, subtitleText: "please_try_again_title".localized, touchAction: .patchGhostCard)
                default:
                    configure(imageName: "lcdModuleIconsPointsLogin", titleText: "log_in_failed_title".localized, subtitleText: "please_try_again_title".localized, touchAction: .loginChanges)
                    break
                }
            } else {
                // Link module 2.7
                configure(imageName: "lcdModuleIconsPointsLogin", titleText: "error_title".localized, subtitleText: "please_try_again_title".localized, touchAction: .noReasonCode)
            }
            break
        default:
            return
        }
    }
}
