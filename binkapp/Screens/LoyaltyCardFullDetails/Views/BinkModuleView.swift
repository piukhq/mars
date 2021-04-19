import UIKit

protocol BinkModuleViewDelegate: class {
    func binkModuleViewWasTapped(moduleView: BinkModuleView, withAction action: ModuleState)
}

class BinkModuleView: CustomView {
    @IBOutlet private weak var moduleImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    
    private var state: ModuleState?
    private weak var delegate: BinkModuleViewDelegate?
    
    func configure(moduleType: ModuleType, delegate: BinkModuleViewDelegate? = nil) {
        guard let stateFromModuleType = state(from: moduleType) else { return }
        self.delegate = delegate
        state = stateFromModuleType
        configure(for: stateFromModuleType)
        
        layer.applyDefaultBinkShadow()
    }
    
    // MARK: - Actions
    
    @IBAction func pointsModuleTapped(_ sender: Any) {
        if let binkModuleAction = state {
            delegate?.binkModuleViewWasTapped(moduleView: self, withAction: binkModuleAction)
        }
    }
}

// MARK: - Private methods

private extension BinkModuleView {
    func state(from moduleType: ModuleType) -> ModuleState? {
        switch moduleType {
        case .points(let membershipCard):
            return pointsState(membershipCard: membershipCard)
        case .link(let membershipCard, let paymentCards):
            return linkState(membershipCard: membershipCard, paymentCards: paymentCards)
        }
    }
    
    func pointsState(membershipCard: CD_MembershipCard) -> ModuleState? {
        guard let plan = membershipCard.membershipPlan, plan.featureSet?.hasPoints?.boolValue ?? false || plan.featureSet?.transactionsAvailable?.boolValue ?? false else {
            // Points module 1.5
            return .loginUnavailable
        }
        
        switch membershipCard.status?.status {
        case .authorised:
            // PLR
            if membershipCard.membershipPlan?.isPLR == true {
                if membershipCard.membershipPlan?.featureSet?.transactionsAvailable?.boolValue == true {
                    return .transactions(transactionsAvailable: true, lastCheckedString: nil, formattedTitle: nil)
                } else {
                    return .aboutMembership
                }
            }

            // Points module 1.1, 1.2
            if let balances = membershipCard.balances.allObjects as? [CD_MembershipCardBalance], let balance = balances.first, let value = balance.value {
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
                return .transactions(transactionsAvailable: transactionsAvailable, lastCheckedString: date.timeAgoString(short: true), formattedTitle: titleText)
            } else {
                return .pending
            }
        case .pending:
            return .pending
        case .failed, .unauthorised:
            if let reasonCode = membershipCard.status?.formattedReasonCodes?.first {
                switch reasonCode {
                case .enrolmentDataRejectedByMerchant:
                    // Points module 1.8
                    return .signUp
                case .accountNotRegistered:
                    // Points module 1.x (to be defined)
                    return .patchGhostCard(type: .points(membershipCard: membershipCard))
                case .accountAlreadyExists:
                    // Points module 1.12
                    return .loginChanges(type: .points(membershipCard: membershipCard), status: membershipCard.status?.status)
                case .accountDoesNotExist, .addDataRejectedByMerchant, .NoAuthorizationProvided, .updateFailed, .noAuthorizationRequired, .authorizationDataRejectedByMerchant, .authorizationExpired, .pointsScrapingLoginFailed:
                    
                    // Points module 1.6
                    return .loginChanges(type: .points(membershipCard: membershipCard), status: membershipCard.status?.status)
                default:
                    // Points module 1.10 (need reason codes, set by default)
                    return .registerGhostCard
                }
            } else {
                return .noReasonCode
            }
        default: return nil
        }
    }
    
    func linkState(membershipCard: CD_MembershipCard, paymentCards: [CD_PaymentCard]?) -> ModuleState? {
        guard let plan = membershipCard.membershipPlan else { return nil }

        guard plan.featureSet?.planCardType == .link else {
            switch plan.featureSet?.planCardType {
            case .store, .view:
                // Link module 2.8
                return .unlinkable
            default:
                // Link module 2.4
                return .genericError
            }
        }
        
        switch membershipCard.status?.status {
        case .authorised:
            let possiblyLinkedCard = paymentCards?.first(where: { !$0.linkedMembershipCards.isEmpty })
            guard membershipCard.linkedPaymentCards.isEmpty, !membershipCard.linkedPaymentCards.contains(possiblyLinkedCard as Any) else {
                // Link module 2.1
                return .pll(membershipCard: membershipCard, paymentCards: paymentCards, error: false)
            }
            if paymentCards?.isEmpty == true {
                // Link module 2.2
                return .pllEmpty
            } else {
                // Link module 2.3
                return .pll(membershipCard: membershipCard, paymentCards: paymentCards, error: true)
            }
        case .unauthorised:
            // Link module 2.5
            return .loginChanges(type: .link(membershipCard: membershipCard, paymentCards: paymentCards), status: membershipCard.status?.status)
        case .pending:
            // Link module 2.6
            return .pending
        case .failed:
            if let reasonCode = membershipCard.status?.formattedReasonCodes?.first {
                switch reasonCode {
                case .enrolmentDataRejectedByMerchant:
                    return .signUp
                case .accountNotRegistered:
                    return .patchGhostCard(type: .link(membershipCard: membershipCard, paymentCards: paymentCards))
                default:
                    return .loginChanges(type: .link(membershipCard: membershipCard, paymentCards: paymentCards), status: .failed)
                }
            } else {
                // Link module 2.7
                return .noReasonCode
            }
        default: return nil
        }
    }
    
    func configure(for state: ModuleState) {
        contentView.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
        moduleImageView.image = UIImage(named: state.imageName)
        titleLabel.text = state.titleText
        titleLabel.textColor = Current.themeManager.color(for: .text)
        subtitleLabel.text = state.subtitleText
        subtitleLabel.textColor = Current.themeManager.color(for: .text)
//        state = touchAction
    }
}
