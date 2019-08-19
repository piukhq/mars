//
//  AddingOptionsViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 02/08/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class AddingOptionsViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    
    let viewModel: AddingOptionsViewModel
    
    let loyaltyCardView = AddingOptionView()
    let browseBrandsView = AddingOptionView()
    let addPaymentCardView = AddingOptionView()
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        viewModel.popViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    init(viewModel: AddingOptionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "AddingOptionsViewController", bundle: Bundle(for: AddingOptionsViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func configureUI() {
        loyaltyCardView.configure(addingOption: .loyalty)
        browseBrandsView.configure(addingOption: .browse)
        addPaymentCardView.configure(addingOption: .payment)
        
        addGesturesToViews()

        stackView.addArrangedSubview(loyaltyCardView)
        stackView.addArrangedSubview(browseBrandsView)
        stackView.addArrangedSubview(addPaymentCardView)
        
    }
    
    func addGesturesToViews() {
        loyaltyCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.toAddLoyaltyCard)))
        browseBrandsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.toBrowseBrands)))
        addPaymentCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.toAddPaymentCard)))
    }
    
    @objc func toAddLoyaltyCard() {
        print("first option tapped")
    }
    
    @objc func toBrowseBrands() {
        print("second option tapped")
    }
    
    @objc func toAddPaymentCard() {
        print("third option tapped")
    }
}
