//
//  AddOrJoinViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class AddOrJoinViewController: BinkViewController {
    private enum Constants {
        static let horizontalInset: CGFloat = 25.0
        static let bottomInset: CGFloat = 150.0
        static let postBrandHeaderViewPadding: CGFloat = 20.0
    }
    
    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [brandHeaderView], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.margin = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.bottomInset, right: 0)
        stackView.customPadding(Constants.postBrandHeaderViewPadding, after: brandHeaderView)
        view.addSubview(stackView)
        return stackView
    }()
    
    private lazy var brandHeaderView: BrandHeaderView = {
        let brandHeader = BrandHeaderView()
        brandHeader.heightAnchor.constraint(equalToConstant: 130).isActive = true
        return brandHeader
    }()
    
    private let viewModel: AddOrJoinViewModel

    private lazy var addCardButton: BinkButton = {
        return BinkButton(type: .capsule, title: L10n.addMyCardButton) { [weak self] in
            self?.viewModel.toAuthAndAddScreen()
        }
    }()

    private lazy var getNewCardButton: BinkButton = {
        return BinkButton(type: .capsule, title: L10n.getNewCardButton) { [weak self] in
            self?.viewModel.didSelectAddNewCard()
        }
    }()
    
    init(viewModel: AddOrJoinViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
        stackScrollView.add(arrangedSubview: storeView)
        let viewView = LoyaltyPlanView()
        viewView.configure(for: .viewCell, cardType: cardType)
        stackScrollView.add(arrangedSubview: viewView)
        let linkView = LoyaltyPlanView()
        linkView.configure(for: .linkCell, cardType: cardType)
        stackScrollView.add(arrangedSubview: linkView)

        var buttons: [BinkButton] = []
        if viewModel.shouldShowAddCardButton {
            buttons.append(addCardButton)
        }
        if viewModel.shouldShowNewCardButton {
            buttons.append(getNewCardButton)
        }
        footerButtons = buttons
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
