//
//  AddOrJoinViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class AddOrJoinViewController: UIViewController {
    @IBOutlet private weak var brandHeaderView: BrandHeaderView!
    @IBOutlet private weak var plansStackView: UIStackView!
    @IBOutlet private weak var addCardButton: BinkGradientButton!
    @IBOutlet private weak var newCardButton: BinkGradientButton!
    private let viewModel: AddOrJoinViewModel
    
    @IBAction func addCardButtonAction(_ sender: Any) {
        viewModel.toAuthAndAddScreen()
    }
    
    @IBAction func newCardButtonAction(_ sender: Any) {
        viewModel.displaySimplePopup(title: nil, message: "Screen not implemented")
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
    
    func setNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let closeButton = UIBarButtonItem(image: UIImage(named: "close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popToRootScreen))
        self.navigationItem.setRightBarButton(closeButton, animated: true)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
        self.navigationItem.leftBarButtonItem = backButton
        
        navigationItem.setHidesBackButton(false, animated: true)
        self.title = ""
    }
    
    func configureUI() {
        let membershipPlan = viewModel.getMembershipPlan()
        
        brandHeaderView.configure(imageURLString: ((membershipPlan.images?.first(where: { $0.type == ImageType.icon.rawValue })?.url) ?? nil), loyaltyPlanNameCard: (membershipPlan.account?.planNameCard ?? nil), delegate: self)
        
        addCardButton.titleLabel?.font = UIFont.buttonText
        addCardButton.setTitle("add_my_card_button".localized, for: .normal)
        
        newCardButton.titleLabel?.font = UIFont.buttonText
        newCardButton.setTitle("get_new_card_button".localized, for: .normal)
        
        guard let cardType = membershipPlan.featureSet?.cardType else { return }
        let storeView = LoyaltyPlanView()
        storeView.configure(for: .storeCell, cardType: cardType)
        plansStackView.addArrangedSubview(storeView)
        let viewView = LoyaltyPlanView()
        viewView.configure(for: .viewCell, cardType: cardType)
        plansStackView.addArrangedSubview(viewView)
        let linkView = LoyaltyPlanView()
        linkView.configure(for: .linkCell, cardType: cardType)
        plansStackView.addArrangedSubview(linkView)
    }
    
    @objc func popViewController() {
        viewModel.popViewController()
    }
    
    @objc func popToRootScreen() {
        viewModel.popToRootViewController()
    }
}

extension AddOrJoinViewController: LoyaltyButtonDelegate {
    func buttonWasPressed() {
        viewModel.displaySimplePopup(title: (viewModel.getMembershipPlan().account?.planNameCard) ?? nil, message: (viewModel.getMembershipPlan().account?.planDescription) ?? nil)
    }
}
