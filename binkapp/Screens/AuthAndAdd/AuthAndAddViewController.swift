//
//  AuthAndAddViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import NotificationCenter

class AuthAndAddViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var brandHeaderView: BrandHeaderView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var fieldsStackView: UIStackView!
    @IBOutlet private weak var loginButton: BinkGradientButton!
    
    private let viewModel: AuthAndAddViewModel
    private var isKeyboardOpen = false
    
    init(viewModel: AuthAndAddViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "AuthAndAddViewController", bundle: Bundle(for: AuthAndAddViewController.self))
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
        let closeButton = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: #selector(popToRootScreen))
        closeButton.tintColor = .black
        self.navigationItem.setRightBarButton(closeButton, animated: true)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
        self.navigationItem.leftBarButtonItem = backButton
        
        navigationItem.setHidesBackButton(false, animated: true)
    }
    
    func configureUI() {
        let membershipPlan = viewModel.getMembershipPlan()
        
        brandHeaderView.configure(imageURLString: ((membershipPlan.firstIconImage()?.url) ?? nil), loyaltyPlanNameCard: (membershipPlan.account?.planNameCard ?? nil), delegate: self)
        
        titleLabel.text = "log_in_title".localized
        titleLabel.font = UIFont.headline
        
        if let planName = membershipPlan.account?.planName {
            descriptionLabel.text = String(format: "auth_screen_description".localized, planName)
            descriptionLabel.font = UIFont.bodyTextLarge
            descriptionLabel.isHidden = false
        }
        
        loginButton.setTitle("log_in_title".localized, for: .normal)
        
        viewModel.populateStackView(stackView: fieldsStackView)
    }
    
    @objc func popViewController() {
        viewModel.popViewController()
    }
    
    @objc func popToRootScreen() {
        viewModel.popToRootViewController()
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        if viewModel.allFieldsAreValid() {
            viewModel.addMembershipCard()
        } else {
            print("Not all fields are valid")
        }
    }
}

extension AuthAndAddViewController: LoyaltyButtonDelegate {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {
        viewModel.displaySimplePopup(title: (viewModel.getMembershipPlan().account?.planNameCard) ?? nil, message: (viewModel.getMembershipPlan().account?.planDescription) ?? nil)
    }
}
