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
    @IBOutlet private weak var addCardButton: BinkGradientButton!
    @IBOutlet private weak var newCardButton: BinkGradientButton!
    private let viewModel: AddOrJoinViewModel
    
    @IBAction func addCardButtonAction(_ sender: Any) {
        viewModel.toAuthAndAddScreen()
    }
    
    @IBAction func newCardButtonAction(_ sender: Any) {
        viewModel.didSelectAddNewCard()
    }
    
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
    
    func setNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.setHidesBackButton(false, animated: true)
        self.title = ""
    }
    
    func configureUI() {
        let membershipPlan = viewModel.getMembershipPlan()
        
        brandHeaderView.configure(plan: membershipPlan, delegate: self)
        
        addCardButton.titleLabel?.font = UIFont.buttonText
        addCardButton.setTitle("add_my_card_button".localized, for: .normal)
        
        newCardButton.titleLabel?.font = UIFont.buttonText
        newCardButton.setTitle("get_new_card_button".localized, for: .normal)

        addCardButton.translatesAutoresizingMaskIntoConstraints = false
        newCardButton.translatesAutoresizingMaskIntoConstraints = false

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

        addCardButton.isHidden = !viewModel.shouldShowAddCardButton
        newCardButton.isHidden = !viewModel.shouldShowNewCardButton
    }
}

extension AddOrJoinViewController: LoyaltyButtonDelegate {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {
        viewModel.brandHeaderWasTapped()
    }
}
