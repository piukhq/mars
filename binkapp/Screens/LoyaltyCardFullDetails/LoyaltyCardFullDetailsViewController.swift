//
//  LoyaltyCardFullDetailsViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class LoyaltyCardFullDetailsViewController: UIViewController {
    @IBOutlet private weak var fullDetailsBrandHeader: FullDetailsBrandHeader!
    @IBOutlet private weak var aboutInfoRow: CardDetailsInfoView!
    @IBOutlet private weak var securityAndPrivacyInfoRow: CardDetailsInfoView!
    @IBOutlet private weak var deleteInfoRow: CardDetailsInfoView!
    @IBOutlet private weak var cardDetailsStackView: UIStackView!
    
    private let viewModel: LoyaltyCardFullDetailsViewModel
    
    init(viewModel: LoyaltyCardFullDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "LoyaltyCardFullDetailsViewController", bundle: Bundle(for: LoyaltyCardFullDetailsViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setCloseButton()
    }
    
    @objc func toTransactionsViewController() {
        viewModel.toTransactionsViewController()
    }
}

// MARK: - Private methods

private extension LoyaltyCardFullDetailsViewController {
    func configureUI() {
        let aboutInfoTitle = "about_membership_title".localized
        let aboutInfoMessage = "learn_more".localized
        aboutInfoRow.delegate = self
        aboutInfoRow.configure(title: aboutInfoTitle, andInfo: aboutInfoMessage)
        
        let securityInfoTitle = "security_and_privacy_title".localized
        let securityInfoMessage = "security_and_privacy_message".localized
        securityAndPrivacyInfoRow.delegate = self
        securityAndPrivacyInfoRow.configure(title: securityInfoTitle, andInfo: securityInfoMessage)
        
        let deleteInfoTitle = "delete_card_title".localized
        let deleteInfoMessage = "delete_card_message".localized
        deleteInfoRow.delegate = self
        deleteInfoRow.configure(title: deleteInfoTitle, andInfo: deleteInfoMessage)
        
        let imageURL = viewModel.membershipPlan.images?.first(where: { $0.type == ImageType.hero.rawValue})?.url ?? nil
        let showBarcode = viewModel.membershipCard.card?.barcode != nil
        fullDetailsBrandHeader.configure(imageUrl: imageURL, showBarcode: showBarcode, delegate: self)
        
        let pointsModuleView = PointsModuleView()
        pointsModuleView.configure(membershipCard: viewModel.membershipCard, membershipPlan: viewModel.membershipPlan, delegate: self)
        cardDetailsStackView.insertArrangedSubview(pointsModuleView, at: 0)
    }
    
    func setCloseButton() {
        let closeButton = UIBarButtonItem(image: UIImage(named: "close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popToRootController
            ))
        self.navigationItem.setLeftBarButton(closeButton, animated: true)
    }
    
    @objc func popToRootController() {
        viewModel.popToRootController()
    }
    
    func displaySecurityAndPrivacyPopup() {
        let securityAdnPrivacyLink = NSURL(string: "https://bink.com/terms-and-conditions/#privacy-policy")
        let messageString = "security_and_privacy_alert_message".localized
        let message = NSMutableAttributedString(string: messageString)
        message.addAttribute(.link, value: securityAdnPrivacyLink ?? "", range: NSRange(location: message.length - 5, length: 4))

        let alert = HyperlinkAlertController(title: "security_and_privacy_alert_title".localized, message: message)
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - CardDetailsInfoViewDelegate

extension LoyaltyCardFullDetailsViewController: CardDetailsInfoViewDelegate {
    func cardDetailsInfoViewDidTapMoreInfo(_ cardDetailsInfoView: CardDetailsInfoView) {
        switch cardDetailsInfoView {
        case aboutInfoRow:
            if let infoMessage = viewModel.membershipPlan.account?.planDescription {
                viewModel.displaySimplePopupWithTitle("Info", andMessage: infoMessage)
            }
            break
        case securityAndPrivacyInfoRow:
            //TODO: Replace me with Terms and Conditions VC when complete
            displaySecurityAndPrivacyPopup()
            break
        case deleteInfoRow:
            viewModel.showDeleteConfirmationAlert(yesCompletion: {
                NotificationCenter.default.post(Notification(name: .didDeleteMemebershipCard))
                self.popToRootController()
            }) {}
            break
        default:
            break
        }
    }
}

// MARK: - FullDetailsBrandHeaderDelegate

extension LoyaltyCardFullDetailsViewController: FullDetailsBrandHeaderDelegate {
    func fullDetailsBrandHeaderDidTapShowBarcode(_ fullDetailsBrandHeader: FullDetailsBrandHeader) {
        viewModel.toBarcodeModel()
    }
}

// MARK: - PointsModuleViewDelegate

extension LoyaltyCardFullDetailsViewController: PointsModuleViewDelegate {
    func pointsModuleViewWasTapped(_: PointsModuleView, withAction action: PointsModuleView.PointsModuleAction) {
        viewModel.goToScreenForAction(action: action)
    }
}
