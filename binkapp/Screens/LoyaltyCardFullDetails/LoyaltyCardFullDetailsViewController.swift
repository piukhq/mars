//
//  LoyaltyCardFullDetailsViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class LoyaltyCardFullDetailsViewController: UIViewController, BarBlurring {
    @IBOutlet private weak var fullDetailsBrandHeader: FullDetailsBrandHeader!
    @IBOutlet private weak var aboutInfoRow: CardDetailsInfoView!
    @IBOutlet private weak var securityAndPrivacyInfoRow: CardDetailsInfoView!
    @IBOutlet private weak var deleteInfoRow: CardDetailsInfoView!
    @IBOutlet private weak var offersStackView: UIStackView!
    @IBOutlet private weak var cardDetailsStackView: UIStackView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private let viewModel: LoyaltyCardFullDetailsViewModel
    internal lazy var blurBackground = defaultBlurredBackground()
    
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

        scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureCardDetails(viewModel.paymentCards)
    }
    
    // MARK: - Navigation Bar Blurring
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let bar = navigationController?.navigationBar else { return }
        prepareBarWithBlur(bar: bar, blurBackground: blurBackground)
    }
}

// MARK: - Private methods

private extension LoyaltyCardFullDetailsViewController {
    func configureUI() {
        if let offerTileImageUrls = viewModel.getOfferTileImageUrls() {
            for offer in offerTileImageUrls {
                let offerView = OfferTileView()
                offerView.configure(imageUrl: offer)
                offersStackView.addArrangedSubview(offerView)
            }
        }
        
        configureCardDetails(viewModel.paymentCards)
        
        let aboutInfoTitle = viewModel.aboutTitle
        let aboutInfoMessage = "learn_more".localized
        aboutInfoRow.delegate = self
        aboutInfoRow.configure(title: aboutInfoTitle, andInfo: aboutInfoMessage)
        
        let securityInfoTitle = "security_and_privacy_title".localized
        let securityInfoMessage = "security_and_privacy_message".localized
        securityAndPrivacyInfoRow.delegate = self
        securityAndPrivacyInfoRow.configure(title: securityInfoTitle, andInfo: securityInfoMessage)
        
        let deleteInfoTitle = viewModel.deleteTitle
        let deleteInfoMessage = "delete_card_message".localized
        deleteInfoRow.delegate = self
        deleteInfoRow.configure(title: deleteInfoTitle, andInfo: deleteInfoMessage)
        
        let imageURL = viewModel.membershipCard.membershipPlan?.image(of: ImageType.hero.rawValue)?.url
        let showBarcode = viewModel.membershipCard.card?.barcode != nil
        fullDetailsBrandHeader.configure(imageUrl: imageURL, showBarcode: showBarcode, delegate: self)
    }
    
    func configureCardDetails(_ paymentCards: [CD_PaymentCard]?) {
        if cardDetailsStackView.subviews.count > 0 {
            for subview in cardDetailsStackView.subviews {
                cardDetailsStackView.removeArrangedSubview(subview)
            }
        }
        let pointsModuleView = BinkModuleView()
            pointsModuleView.configure(moduleType: .points, membershipCard: viewModel.membershipCard, delegate: self)
            cardDetailsStackView.addArrangedSubview(pointsModuleView)
        
        let linkModuleView = BinkModuleView()
        linkModuleView.configure(moduleType: .link, membershipCard: viewModel.membershipCard, paymentCards: paymentCards, delegate: self)
        cardDetailsStackView.addArrangedSubview(linkModuleView)
    }
    
    func setCloseButton() {
        let closeButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(popToRootController
            ))
        self.navigationItem.setLeftBarButton(closeButton, animated: true)
    }
    
    @objc func popToRootController() {
        viewModel.popToRootController()
    }
}

// MARK: - CardDetailsInfoViewDelegate

extension LoyaltyCardFullDetailsViewController: CardDetailsInfoViewDelegate {
    func cardDetailsInfoViewDidTapMoreInfo(_ cardDetailsInfoView: CardDetailsInfoView) {
        switch cardDetailsInfoView {
        case aboutInfoRow:
            var title = ""
            
            if let planName = viewModel.membershipCard.membershipPlan?.account?.planName {
                title = String(format: "about_custom_title".localized, planName)
            } else {
                title = "info_title".localized
            }
            
            if let infoMessage = viewModel.membershipCard.membershipPlan?.account?.planDescription {
                let attributedString = NSMutableAttributedString()
                let attributedTitle = NSAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : UIFont.headline])
                let attributedBody = NSAttributedString(string: infoMessage, attributes: [NSAttributedString.Key.font : UIFont.bodyTextLarge])
                attributedString.append(attributedTitle)
                attributedString.append(attributedBody)

                
                viewModel.toReusableModalTemplate(title: title, description: attributedString)
            } else {
                let attributedTitle = NSMutableAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : UIFont.headline])
                
                viewModel.toReusableModalTemplate(title: title, description: attributedTitle)
            }
            break
        case securityAndPrivacyInfoRow:
            viewModel.toSecurityAndPrivacyScreen()
            break
        case deleteInfoRow:
            viewModel.showDeleteConfirmationAlert(yesCompletion: {
                Current.wallet.refreshLocal()
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

extension LoyaltyCardFullDetailsViewController: BinkModuleViewDelegate {
    func binkModuleViewWasTapped(moduleView: BinkModuleView, withAction action: BinkModuleView.BinkModuleAction) {
        viewModel.goToScreenForAction(action: action)
    }
}

// MARK: - Navigation title scrolling behaviour

extension LoyaltyCardFullDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let titleView: DetailNavigationTitleView = .fromNib()
        titleView.configureWithTitle(viewModel.brandName, detail: viewModel.pointsValueText)

        let offset = LayoutHelper.LoyaltyCardDetail.navBarTitleViewScrollOffset
        navigationItem.titleView = scrollView.contentOffset.y > offset ? titleView : nil
    }
}

extension LayoutHelper {
    struct LoyaltyCardDetail {
        static let navBarTitleViewScrollOffset: CGFloat = 100
    }
}
