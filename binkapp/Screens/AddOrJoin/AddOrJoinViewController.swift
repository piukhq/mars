//
//  AddOrJoinViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import CardScan

class AddOrJoinViewController: BinkViewController {
    @IBOutlet private weak var brandHeaderView: BrandHeaderView!
    @IBOutlet private weak var plansStackView: UIStackView!
    private let viewModel: AddOrJoinViewModel

    private lazy var addCardButton: BinkButton = {
        return BinkButton(type: .gradient, title: "add_my_card_button".localized) { [weak self] in
            self?.viewModel.toAuthAndAddScreen()
        }
    }()

    private lazy var getNewCardButton: BinkButton = {
        return BinkButton(type: .gradient, title: "get_new_card_button".localized) { [weak self] in
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
        plansStackView.addArrangedSubview(storeView)
        let viewView = LoyaltyPlanView()
        viewView.configure(for: .viewCell, cardType: cardType)
        plansStackView.addArrangedSubview(viewView)
        let linkView = LoyaltyPlanView()
        linkView.configure(for: .linkCell, cardType: cardType)
        plansStackView.addArrangedSubview(linkView)

        var buttons: [BinkButton] = []
        if viewModel.shouldShowAddCardButton {
            buttons.append(addCardButton)
        }
        if viewModel.shouldShowNewCardButton {
            buttons.append(getNewCardButton)
        }
        footerButtons = buttons
    }
}

extension AddOrJoinViewController: LoyaltyButtonDelegate {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {
        viewModel.brandHeaderWasTapped()
    }
}
