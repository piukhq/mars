//
//  AddOrJoinViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import CardScan

class AddOrJoinViewController: BinkViewController {
//    @IBOutlet private weak var brandHeaderView: BrandHeaderView!
//    @IBOutlet private weak var plansStackView: UIStackView!
    
    private enum Constants {
//        static let normalCellHeight: CGFloat = 84.0
        static let horizontalInset: CGFloat = 25.0
        static let bottomInset: CGFloat = 150.0
//        static let postCollectionViewPadding: CGFloat = 15.0
//        static let offsetPadding: CGFloat = 30.0
    }
    
    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [brandHeaderView], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.margin = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.bottomInset, right: 0)
//        stackView.customPadding(Constants.postCollectionViewPadding, after: collectionView)
        view.addSubview(stackView)
        return stackView
    }()
    
    private lazy var brandHeaderView: BrandHeaderView = {
        let brandHeader = BrandHeaderView()
        brandHeader.heightAnchor.constraint(equalToConstant: 110).isActive = true
        return brandHeader
    }()
    
    private let viewModel: AddOrJoinViewModel

    private lazy var addCardButton: BinkButton = {
        return BinkButton(type: .gradient, title: L10n.addMyCardButton) { [weak self] in
            self?.viewModel.toAuthAndAddScreen()
        }
    }()

    private lazy var getNewCardButton: BinkButton = {
        return BinkButton(type: .gradient, title: L10n.getNewCardButton) { [weak self] in
            self?.viewModel.didSelectAddNewCard()
        }
    }()
    
    init(viewModel: AddOrJoinViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "AddOrJoinViewController", bundle: Bundle(for: AddOrJoinViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        configureUI()
        configureLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .storeViewLink)
    }
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        let membershipPlan = viewModel.getMembershipPlan()
        brandHeaderView.configure(plan: membershipPlan, delegate: self)
    }
    
    func setNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.setHidesBackButton(false, animated: true)
        self.title = ""
    }
    
    func configureUI() {
        let membershipPlan = viewModel.getMembershipPlan()
        
        brandHeaderView.configure(plan: membershipPlan, delegate: self)

        guard let cardType = membershipPlan.featureSet?.planCardType else { return }
        let storeView = LoyaltyPlanView()
        storeView.configure(for: .storeCell, cardType: cardType)
//        stackScrollView.addArrangedSubview(storeView)
        stackScrollView.add(arrangedSubview: storeView)
        let viewView = LoyaltyPlanView()
        viewView.configure(for: .viewCell, cardType: cardType)
//        stackScrollView.addArrangedSubview(viewView)
        stackScrollView.add(arrangedSubview: viewView)
        let linkView = LoyaltyPlanView()
        linkView.configure(for: .linkCell, cardType: cardType)
//        stackScrollView.addArrangedSubview(linkView)
        stackScrollView.add(arrangedSubview: linkView)

        var buttons: [BinkButton] = []
        if viewModel.shouldShowAddCardButton {
            buttons.append(addCardButton)
        }
        if viewModel.shouldShowNewCardButton {
            buttons.append(getNewCardButton)
        }
//        footerButtons = buttons
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}

extension AddOrJoinViewController: LoyaltyButtonDelegate {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {
        viewModel.brandHeaderWasTapped()
    }
}
