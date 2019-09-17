//
//  PointsModuleView.swift
//  binkapp
//
//  Created by Dorin Pop on 12/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol PointsModuleViewDelegate {
    func pointsModuleViewWasTapped(_: PointsModuleView, withAction action: PointsModuleView.PointsModuleAction)
}

class PointsModuleView: CustomView {
    @IBOutlet private weak var moduleImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    enum PointsModuleAction: Int {
        case login = 0
        case loginChanges
        case transactions
        case loginPending
        case loginUnavailable
        case signUp
        case registerGhostCard
    }
    
    private var action: PointsModuleAction?
    private var delegate: PointsModuleViewDelegate?
    
    func configure(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel, delegate: PointsModuleViewDelegate) {
        self.delegate = delegate
        layer.shadowColor = UIColor.black.cgColor
        
        guard membershipPlan.featureSet?.hasPoints ?? false || membershipPlan.featureSet?.transactionsAvailable ?? false else {
            // Points module 1.5
            configure(imageName: "lcdModuleIconsPointsInactive", titleText: "history_title".localized, subtitleText: "not_available_title".localized, touchAction: .loginUnavailable)
            return
        }
        
        switch membershipCard.status?.state {
        case MembershipCardStatusModel.MembershipCardStatus.authorised.rawValue:
            // Points module 1.1, 1.2
            if let balances = membershipCard.balances, let value = balances[0].value {
                let titleText = (balances[0].prefix ?? "") + String(value) + " " + (balances[0].suffix ?? "")
                let subtitleText = (membershipPlan.featureSet?.transactionsAvailable ?? false) ? "points_module_view_history_message".localized : "points_module_last_checked".localized + (balances[0].updatedAt?.stringFromTimeInterval() ?? "")
                configure(imageName: "lcdModuleIconsPointsActive", titleText: titleText, subtitleText: subtitleText, touchAction: .transactions)
            }
            break
        case MembershipCardStatusModel.MembershipCardStatus.unauthorised.rawValue:
            // Points Module 1.3, 1.4
            configure(imageName: "lcdModuleIconsPointsLogin", titleText: "log_in_title".localized, subtitleText: "points_module_to_see_history".localized, touchAction: .login)
            break
        case MembershipCardStatusModel.MembershipCardStatus.pending.rawValue:
            let imageName = "lcdModuleIconsPointsLoginPending"
            if let reasonCodes = membershipCard.status?.reasonCodes, reasonCodes.count > 0 {
                switch reasonCodes[0] {
                case "X200":
                    // Points module 1.9
                    configure(imageName: imageName, titleText: "points_module_signing_up_status".localized, subtitleText: "please_wait_title".localized, touchAction: .loginPending)
                    break
                case "X000", "X301":
                    // Points module 1.7
                    configure(imageName: imageName, titleText: "points_module_signing_up_status".localized, subtitleText: "please_wait_title".localized, touchAction: .loginPending)
                    break
                default:
                    // Points module 1.11 (need reason codes, set by defaul)
                    configure(imageName: imageName, titleText: "points_module_registering_card_status".localized, subtitleText: "please_wait_title".localized, touchAction: .loginPending)
                    break
                }
            } else {
                isHidden = true
            }
            break
        case MembershipCardStatusModel.MembershipCardStatus.failed.rawValue:
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
            } else {
                isHidden = true
            }
            break
        default:
            return
        }
    }
    
    // MARK: - Actions
    
    @IBAction func pointsModuleTapepd(_ sender: Any) {
        if let pointsModuleAction = action {
            delegate?.pointsModuleViewWasTapped(self, withAction: pointsModuleAction)
        }
    }
}

// MARK: - Private methods

private extension PointsModuleView {
    func configure(imageName: String, titleText: String, subtitleText: String, touchAction: PointsModuleAction) {
        moduleImageView.image = UIImage(named: imageName)
        titleLabel.text = titleText
        subtitleLabel.text = subtitleText
        action = touchAction
    }
}
