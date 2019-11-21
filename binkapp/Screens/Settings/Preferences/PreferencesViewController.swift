//
//  PreferencesViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PreferencesViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    private let viewModel: PreferencesViewModel
    private var checkboxes: [CheckboxView] = []
    
    init(viewModel: PreferencesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        navigationItem.leftBarButtonItem = backButton
        
        titleLabel.text = "settings_row_preferences_title".localized
        titleLabel.font = UIFont.headline
        
        let attributedString = NSMutableAttributedString(string: "preferences_screen_description".localized, attributes: [
            .font: UIFont.bodyTextLarge
        ])
        attributedString.addAttribute(.font, value: UIFont.subtitle, range: NSRange(location: 51, length: 7))
        attributedString.addAttribute(.font, value: UIFont.subtitle, range: NSRange(location: 60, length: 6))
        attributedString.addAttribute(.font, value: UIFont.subtitle, range: NSRange(location: 71, length: 7))
        descriptionLabel.attributedText = attributedString
        
    }
    
    private func setCheckboxes() {
        let checkboxView = CheckboxView()
        checkboxView.configure(title: "preferences_marketing_checkbox".localized, columnName: "preferences_marketing_checkbox".localized, columnKind: .add, delegate: self)
        
        checkboxes.append(checkboxView)
        
        
    }
    
    @objc private func popViewController() {
        viewModel.popViewController()
    }
}

extension PreferencesViewController: CheckboxViewDelegate {
    func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FormField.ColumnKind) {
        
    }
}
