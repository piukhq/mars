//
//  LoyaltyCardFullDetailsViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class LoyaltyCardFullDetailsViewController: UIViewController, BarBlurring {

    // MARK: - UI Lazy Variables

    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: nil, adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.margin = LayoutHelper.PaymentCardDetail.stackScrollViewMargins
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.contentInset = LayoutHelper.PaymentCardDetail.stackScrollViewContentInsets
        view.addSubview(stackView)
        return stackView
    }()

    private lazy var brandHeader: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(showBarcodeButtonPressed))
        imageView.addGestureRecognizer(gestureRecogniser)
        return imageView
    }()

    private lazy var showBarcodeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .bodyTextLarge
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(showBarcodeButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var modulesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()

    private lazy var offerTilesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    lazy var informationTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let viewModel: LoyaltyCardFullDetailsViewModel
    internal lazy var blurBackground = defaultBlurredBackground()
    
    init(viewModel: LoyaltyCardFullDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setCloseButton()

        stackScrollView.delegate = self

        stackScrollView.add(arrangedSubview: brandHeader)
        brandHeader.clipsToBounds = true
        brandHeader.layer.cornerRadius = 12
        if let imageURL = viewModel.membershipCard.membershipPlan?.image(of: ImageType.hero.rawValue)?.url {
            if let url = URL(string: imageURL) {
                brandHeader.af_setImage(withURL: url)
            }
        }

        stackScrollView.customPadding(12, after: brandHeader)

        // TODO: Use viewmodel to check if the offer tiles will be shown
        let showBarcode = viewModel.membershipCard.card?.barcode != nil
        let buttonTitle = showBarcode ? "details_header_show_barcode".localized : "details_header_show_card_number".localized
        showBarcodeButton.setTitle(buttonTitle, for: .normal)
        stackScrollView.add(arrangedSubview: showBarcodeButton)

        stackScrollView.customPadding(25, after: showBarcodeButton)

        stackScrollView.add(arrangedSubview: modulesStackView)
        configureCardDetails(viewModel.paymentCards)

        stackScrollView.customPadding(25, after: modulesStackView)

        // TODO: Use viewmodel to check if the offer tiles will be shown
        stackScrollView.add(arrangedSubview: offerTilesStackView)
        if let offerTileImageUrls = viewModel.getOfferTileImageUrls() {
            offerTileImageUrls.forEach { offer in
                let offerView = OfferTileView()
                offerView.translatesAutoresizingMaskIntoConstraints = false
                offerView.configure(imageUrl: offer)
                offerTilesStackView.addArrangedSubview(offerView)
            }
        }

        stackScrollView.customPadding(12, after: offerTilesStackView)

        stackScrollView.add(arrangedSubview: informationTableView)
        informationTableView.delegate = self
        informationTableView.dataSource = self
        informationTableView.register(CardDetailInfoTableViewCell.self, asNib: true)
        informationTableView.separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)

        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            brandHeader.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: 25),
            brandHeader.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -25),
            brandHeader.heightAnchor.constraint(equalTo: brandHeader.widthAnchor, multiplier: 115/182),
            showBarcodeButton.heightAnchor.constraint(equalToConstant: 22),
            modulesStackView.heightAnchor.constraint(equalToConstant: 128),
            modulesStackView.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: 25),
            modulesStackView.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -25),
            offerTilesStackView.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: 25),
            offerTilesStackView.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -25),
            informationTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
        ])

        configureUI()
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

// MARK: - Table view

extension LoyaltyCardFullDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.informationRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CardDetailInfoTableViewCell = tableView.dequeue(indexPath: indexPath)

        let informationRow = viewModel.informationRow(forIndexPath: indexPath)
        cell.configureWithInformationRow(informationRow)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.performActionForInformationRow(atIndexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
}

// MARK: - Private methods

private extension LoyaltyCardFullDetailsViewController {
    func setCloseButton() {
        let closeButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(popToRootController
            ))
        self.navigationItem.setLeftBarButton(closeButton, animated: true)
    }

    func configureUI() {
//
//
//        let aboutInfoTitle = viewModel.aboutTitle
//        let aboutInfoMessage = "learn_more".localized
//        aboutInfoRow.delegate = self
//        aboutInfoRow.configure(title: aboutInfoTitle, andInfo: aboutInfoMessage)
//
//        let securityInfoTitle = "security_and_privacy_title".localized
//        let securityInfoMessage = "security_and_privacy_message".localized
//        securityAndPrivacyInfoRow.delegate = self
//        securityAndPrivacyInfoRow.configure(title: securityInfoTitle, andInfo: securityInfoMessage)
//
//        let deleteInfoTitle = viewModel.deleteTitle
//        let deleteInfoMessage = "delete_card_message".localized
//        deleteInfoRow.delegate = self
//        deleteInfoRow.configure(title: deleteInfoTitle, andInfo: deleteInfoMessage)
//
//        let imageURL = viewModel.membershipCard.membershipPlan?.image(of: ImageType.hero.rawValue)?.url
//        let showBarcode = viewModel.membershipCard.card?.barcode != nil
//        brandHeader.configure(imageUrl: imageURL, showBarcode: showBarcode, delegate: self)
    }
    
    func configureCardDetails(_ paymentCards: [CD_PaymentCard]?) {
        if modulesStackView.subviews.count > 0 {
            for subview in modulesStackView.subviews {
                modulesStackView.removeArrangedSubview(subview)
            }
        }

        let pointsModuleView = BinkModuleView()
        pointsModuleView.configure(moduleType: .points, membershipCard: viewModel.membershipCard, delegate: self)
        modulesStackView.addArrangedSubview(pointsModuleView)

        let linkModuleView = BinkModuleView()
        linkModuleView.configure(moduleType: .link, membershipCard: viewModel.membershipCard, paymentCards: paymentCards, delegate: self)
        modulesStackView.addArrangedSubview(linkModuleView)
    }
    
    @objc func popToRootController() {
        viewModel.popToRootController()
    }

    @objc func showBarcodeButtonPressed() {
        viewModel.toBarcodeModel()
    }
}

// MARK: - CardDetailsInfoViewDelegate

//extension LoyaltyCardFullDetailsViewController: CardDetailsInfoViewDelegate {
//    func cardDetailsInfoViewDidTapMoreInfo(_ cardDetailsInfoView: CardDetailsInfoView) {
//        switch cardDetailsInfoView {
//        case aboutInfoRow:
//            var title = ""
//
//            if let planName = viewModel.membershipCard.membershipPlan?.account?.planName {
//                title = String(format: "about_custom_title".localized, planName)
//            } else {
//                title = "info_title".localized
//            }
//
//            if let infoMessage = viewModel.membershipCard.membershipPlan?.account?.planDescription {
//                let attributedString = NSMutableAttributedString()
//                let attributedTitle = NSAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : UIFont.headline])
//                let attributedBody = NSAttributedString(string: infoMessage, attributes: [NSAttributedString.Key.font : UIFont.bodyTextLarge])
//                attributedString.append(attributedTitle)
//                attributedString.append(attributedBody)
//
//
//                viewModel.toReusableModalTemplate(title: title, description: attributedString)
//            } else {
//                let attributedTitle = NSMutableAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : UIFont.headline])
//
//                viewModel.toReusableModalTemplate(title: title, description: attributedTitle)
//            }
//            break
//        case securityAndPrivacyInfoRow:
//            viewModel.toSecurityAndPrivacyScreen()
//            break
//        case deleteInfoRow:
//            viewModel.showDeleteConfirmationAlert(yesCompletion: {
//                Current.wallet.refreshLocal()
//                self.popToRootController()
//            }) {}
//            break
//        default:
//            break
//        }
//    }
//}

// MARK: - CardDetailInformationRowFactoryDelegate

extension LoyaltyCardFullDetailsViewController: CardDetailInformationRowFactoryDelegate {
    func cardDetailInformationRowFactory(_ factory: PaymentCardDetailInformationRowFactory, shouldPerformActionForRowType informationRowType: CardDetailInformationRow.RowType) {
        switch informationRowType {
        case .securityAndPrivacy:
            viewModel.toSecurityAndPrivacyScreen()
        case .deletePaymentCard:
            viewModel.deleteMembershipCard()
        }
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
