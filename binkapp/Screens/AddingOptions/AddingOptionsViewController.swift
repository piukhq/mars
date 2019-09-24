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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    init(viewModel: AddingOptionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "AddingOptionsViewController", bundle: Bundle(for: AddingOptionsViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func configureUI() {
        self.title = ""
        
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
        displayNoScreenPopup()
    }
    
    @objc func toBrowseBrands() {
        viewModel.toBrowseBrandsScreen()
    }
    
    @objc func toAddPaymentCard() {
        viewModel.toAddPaymentCardScreen()
    }
    
    func displayNoScreenPopup() {
         let alert = UIAlertController(title: nil, message: "Screen was not implemented yet", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
