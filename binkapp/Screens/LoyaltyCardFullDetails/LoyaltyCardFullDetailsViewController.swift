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
        stackView.backgroundColor = .clear
        stackView.margin = LayoutHelper.PaymentCardDetail.stackScrollViewMargins
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.delegate = self
        stackView.contentInset = LayoutHelper.PaymentCardDetail.stackScrollViewContentInsets
        return stackView
    }()

    private lazy var brandHeader: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.contentMode = .scaleAspectFill
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(showBarcodeButtonPressed))
        imageView.addGestureRecognizer(gestureRecogniser)
        imageView.layer.applyDefaultBinkShadow()
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
        let stackView = UIStackView(arrangedSubviews: [pointsModule, linkModule])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()

    private lazy var pointsModule: BinkModuleView = {
        return BinkModuleView()
    }()

    private lazy var linkModule: BinkModuleView = {
        return BinkModuleView()
    }()

    private lazy var plrCollectionView: NestedCollectionView = {
        let collectionView = NestedCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        collectionView.register(PLRAccumulatorActiveCell.self, asNib: true)
        return collectionView
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

    lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = .lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()

    lazy var informationTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CardDetailInfoTableViewCell.self, asNib: true)
        tableView.separatorInset = LayoutHelper.LoyaltyCardDetail.informationTableSeparatorInset
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
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureModules()
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

        if tableView.cellAtIndexPathIsLastInSection(indexPath) {
            cell.hideSeparator()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.performActionForInformationRow(atIndexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LayoutHelper.PaymentCardDetail.informationRowCellHeight
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
        view.addSubview(stackScrollView)
        stackScrollView.add(arrangedSubview: brandHeader)
        if let imageURL = viewModel.membershipCard.membershipPlan?.image(of: ImageType.hero.rawValue)?.url {
            if let url = URL(string: imageURL) {
                brandHeader.af_setImage(withURL: url)
            }
        }

        stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.headerToBarcodeButtonPadding, after: brandHeader)

        // TODO: Use viewmodel to check if the offer tiles will be shown
        let showBarcode = viewModel.membershipCard.card?.barcode != nil
        let buttonTitle = showBarcode ? "details_header_show_barcode".localized : "details_header_show_card_number".localized
        showBarcodeButton.setTitle(buttonTitle, for: .normal)
        stackScrollView.add(arrangedSubview: showBarcodeButton)

        stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.contentPadding, after: showBarcodeButton)

        stackScrollView.add(arrangedSubview: modulesStackView)
        configureModules()

        stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.contentPadding, after: modulesStackView)




        stackScrollView.add(arrangedSubview: plrCollectionView)
        stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.contentPadding, after: plrCollectionView)



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

        stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.contentPadding, after: offerTilesStackView)

        stackScrollView.add(arrangedSubview: separator)

        stackScrollView.add(arrangedSubview: informationTableView)

        configureLayout()
    }

    func configureLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            brandHeader.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.LoyaltyCardDetail.contentPadding),
            brandHeader.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.LoyaltyCardDetail.contentPadding),
            brandHeader.heightAnchor.constraint(equalTo: brandHeader.widthAnchor, multiplier: LayoutHelper.LoyaltyCardDetail.brandHeaderAspectRatio),
            showBarcodeButton.heightAnchor.constraint(equalToConstant: LayoutHelper.LoyaltyCardDetail.barcodeButtonHeight),
            modulesStackView.heightAnchor.constraint(equalToConstant: LayoutHelper.LoyaltyCardDetail.modulesStackViewHeight),
            modulesStackView.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.LoyaltyCardDetail.contentPadding),
            modulesStackView.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.LoyaltyCardDetail.contentPadding),
            plrCollectionView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            offerTilesStackView.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.LoyaltyCardDetail.contentPadding),
            offerTilesStackView.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.LoyaltyCardDetail.contentPadding),
            separator.heightAnchor.constraint(equalToConstant: 0.3),
            separator.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            informationTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
        ])
    }
    
    func configureModules() {
        pointsModule.configure(moduleType: .points, membershipCard: viewModel.membershipCard, delegate: self)
        linkModule.configure(moduleType: .link, membershipCard: viewModel.membershipCard, paymentCards: viewModel.paymentCards, delegate: self)
    }
    
    @objc func popToRootController() {
        viewModel.popToRootController()
    }

    @objc func showBarcodeButtonPressed() {
        viewModel.toBarcodeModel()
    }
}

// MARK: - CardDetailInformationRowFactoryDelegate

extension LoyaltyCardFullDetailsViewController: CardDetailInformationRowFactoryDelegate {
    func cardDetailInformationRowFactory(_ factory: PaymentCardDetailInformationRowFactory, shouldPerformActionForRowType informationRowType: CardDetailInformationRow.RowType) {
        switch informationRowType {
        case .about:
            viewModel.toAboutMembershipPlanScreen()
        case .securityAndPrivacy:
            viewModel.toSecurityAndPrivacyScreen()
        case .deleteMembershipCard:
            viewModel.deleteMembershipCard()
        default:
            return
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

// MARK: - PLR Collection View

extension LoyaltyCardFullDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PLRAccumulatorActiveCell = collectionView.dequeue(indexPath: indexPath)
        cell.configure()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 50, height: 188)
    }
}

extension LayoutHelper {
    struct LoyaltyCardDetail {
        static let navBarTitleViewScrollOffset: CGFloat = 100
        static let contentPadding: CGFloat = 25
        static let headerToBarcodeButtonPadding: CGFloat = 12
        static let brandHeaderAspectRatio: CGFloat = 115/182
        static let modulesStackViewHeight: CGFloat = 128
        static let barcodeButtonHeight: CGFloat = 22
        static let informationTableSeparatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
    }
}
