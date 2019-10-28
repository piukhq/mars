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
        viewModel.delegate = self
        viewModel.getPaymentCards()
        configureUI()
        setCloseButton()

        scrollView.delegate = self
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
        
        let imageURL = viewModel.membershipCard.membershipPlan?.image(of: ImageType.hero.rawValue)?.url
        let showBarcode = viewModel.membershipCard.card?.barcode != nil
        fullDetailsBrandHeader.configure(imageUrl: imageURL, showBarcode: showBarcode, delegate: self)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        cardDetailsStackView.addArrangedSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func configureCardDetails(_ paymentCards: [PaymentCardModel]?) {
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
    
    func displaySecurityAndPrivacyPopup() {
        let securityAdnPrivacyLink = NSURL(string: "https://bink.com/terms-and-conditions/#privacy-policy")
        let title = "security_and_privacy_alert_title".localized
        let description = "security_and_privacy_alert_message".localized
        let attributedString = NSMutableAttributedString(string: title + "\n" + description)
        attributedString.addAttribute(.link, value: securityAdnPrivacyLink ?? "", range: NSRange(location: attributedString.length - 5, length: 4))
        attributedString.addAttribute(.font, value: UIFont.headline, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.font, value: UIFont.bodyTextLarge, range: NSRange(location: title.count, length: description.count))
        
        viewModel.toReusableModalTemplate(title: title, description: attributedString)
    }
}

// MARK: - CardDetailsInfoViewDelegate

extension LoyaltyCardFullDetailsViewController: CardDetailsInfoViewDelegate {
    func cardDetailsInfoViewDidTapMoreInfo(_ cardDetailsInfoView: CardDetailsInfoView) {
        switch cardDetailsInfoView {
        case aboutInfoRow:
            let title = viewModel.membershipCard.membershipPlan?.account?.planName ?? "info_title".localized
            if let infoMessage = viewModel.membershipCard.membershipPlan?.account?.planDescription {
                let attributedText = NSMutableAttributedString(string: title + "\n" + infoMessage)
                
                attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.headline, range: NSRange(location: 0, length: title.count))
                attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.bodyTextLarge, range: NSRange(location: title.count, length: infoMessage.count))
                
                viewModel.toReusableModalTemplate(title: title, description: attributedText)
            } else {
                let description = ""
                let attributedText = NSMutableAttributedString(string: title + "\n" + description)
                
                attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.headline, range: NSRange(location: 0, length: title.count))
                attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.bodyTextLarge, range: NSRange(location: title.count, length: description.count))
                
                viewModel.toReusableModalTemplate(title: title, description: attributedText)
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

extension LoyaltyCardFullDetailsViewController: BinkModuleViewDelegate {
    func binkModuleViewWasTapped(moduleView: BinkModuleView, withAction action: BinkModuleView.BinkModuleAction) {
        viewModel.goToScreenForAction(action: action)
    }
}

// MARK: - LoyaltyCardFullDetailsViewModelDelegate

extension LoyaltyCardFullDetailsViewController: LoyaltyCardFullDetailsViewModelDelegate {
    func loyaltyCardFullDetailsViewModelDidFetchPaymentCards(_ loyaltyCardFullDetailsViewModel: LoyaltyCardFullDetailsViewModel, paymentCards: [PaymentCardModel]) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else {return}
            if let activityIndicator = self.cardDetailsStackView.subviews.first {
                activityIndicator.removeFromSuperview()
            }
            self.configureCardDetails(paymentCards)
        }
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
