//
//  LoyaltyCardFullDetailsViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let didDeleteMemebershipCard = Notification.Name("didDeleteMembershipCard")
}

class LoyaltyCardFullDetailsViewController: UIViewController {
    @IBOutlet private weak var fullDetailsBrandHeader: FullDetailsBrandHeader!
    @IBOutlet weak var aboutInfoRow: CardDetailsInfoView!
    @IBOutlet weak var securityAndPrivacyInfoRow: CardDetailsInfoView!
    @IBOutlet weak var deleteInfoRow: CardDetailsInfoView!
    
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
        fullDetailsBrandHeader.configureUI()
        configureUI()
        setCloseButton()
    }
}

// MARK: - Private methods

private extension LoyaltyCardFullDetailsViewController {
    func configureUI() {
        let aboutInfoTitle = "About membership"
        let aboutInfoMessge = "Learn more about how it works"
        aboutInfoRow.delegate = self
        aboutInfoRow.configureWithTitle(title: aboutInfoTitle, andInfo: aboutInfoMessge)
        
        let securityInfoTitle = "Security and privacy"
        let securityInfoMessage = "How we protect your data"
        securityAndPrivacyInfoRow.delegate = self
        securityAndPrivacyInfoRow.configureWithTitle(title: securityInfoTitle, andInfo: securityInfoMessage)
        
        let deleteInfoTitle = "Delete this card"
        let deleteInfoMessage = "Remove this card from Bink"
        deleteInfoRow.delegate = self
        deleteInfoRow.configureWithTitle(title: deleteInfoTitle, andInfo: deleteInfoMessage)
    }
    
    func setCloseButton() {
        let closeButton = UIBarButtonItem(image: UIImage(named: "close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController
            ))
        self.navigationItem.setLeftBarButton(closeButton, animated: true)
    }
    
    @objc func popViewController() {
        viewModel.popViewController()
    }
    
    func popToRootController() {
        viewModel.popToRootController()
    }
    
    func displaySecurityAndPrivacyPopup() {
        let securityAdnPrivacyLink = NSURL(string: "https://bink.com/terms-and-conditions/#privacy-policy")
        let messageString = "We take security very seriously and keeping your personal details safe is very important to us.\nWe are a PCI certified service provider which means that we meet the highest level of security standards set by the payment card industry. This certification requires us to employ a wide range of measures designed to protect the security of your information. We recommend that you secure your app with Touch ID and/or a passcode for an extra layer of security.\nWe carefully check all the parties who we share your personal information with. To find out more you can see our Privacy Policy here."
        let message = NSMutableAttributedString(string: messageString)
        message.addAttribute(.link, value: securityAdnPrivacyLink ?? "", range: NSRange(location: message.length - 5, length: 4))

        let alert = HyperlinkAlertController(title: "Is my Data Secure?", message: message)
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        present(alert, animated: true, completion: nil)
    }
}

extension LoyaltyCardFullDetailsViewController: CardDetailsInfoViewDelegate {
    func cardDetailsInfoViewDidTapMoreInfo(_ cardDetailsInfoView: CardDetailsInfoView) {
        switch cardDetailsInfoView {
        case aboutInfoRow:
            if let infoMessage = viewModel.membershipPlan.account?.planDescription {
                viewModel.displaySimplePopupWithTitle("Info", andMessage: infoMessage)
            }
            break
        case securityAndPrivacyInfoRow:
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
