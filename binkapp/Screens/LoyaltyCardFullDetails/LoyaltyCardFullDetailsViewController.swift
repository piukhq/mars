//
//  LoyaltyCardFullDetailsViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

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
    
    //TODO: Continue with delete.
//    func displayDeletePopup() {
//        let alert = UIAlertController(title: "Are you sure you want to delete this card?", message: nil, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { (action) in
//            <#code#>
//        }))
//        present(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
//    }
    
    @objc func popViewController() {
        viewModel.popViewController()
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
            let message = "We take security very seriously and keeping your personal details safe is very important to us.\nWe are a PCI certified service provider which means that we meet the highest level of security standards set by the payment card industry. This certification requires us to employ a wide range of measures designed to protect the security of your information. We recommend that you secure your app with Touch ID and/or a passcode for an extra layer of security.\nWe carefully check all the parties who we share your personal information with. To find out more you can see our Privacy Policy here."
            viewModel.displaySimplePopupWithTitle("Is my Data Secure?", andMessage: message)
            break
        case deleteInfoRow:
            break
        default:
            break
        }
    }
    
    
}
