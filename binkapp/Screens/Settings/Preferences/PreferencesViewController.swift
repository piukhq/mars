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
    private var modifiedPreferences: [PreferencesModel] = []
    
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
        navigationItem.leftBarButtonItem?.title = nil
        
        titleLabel.text = "settings_row_preferences_title".localized
        titleLabel.font = UIFont.headline
        
        let attributedString = NSMutableAttributedString(string: "preferences_screen_description".localized, attributes: [
            .font: UIFont.bodyTextLarge
        ])
        attributedString.addAttribute(.font, value: UIFont.subtitle, range: NSRange(location: 51, length: 7))
        attributedString.addAttribute(.font, value: UIFont.subtitle, range: NSRange(location: 60, length: 6))
        attributedString.addAttribute(.font, value: UIFont.subtitle, range: NSRange(location: 71, length: 7))
        descriptionLabel.attributedText = attributedString
        
        viewModel.getPreferences { [weak self] (preferences) in
            self?.createCheckboxes(preferences: preferences)
        }
    }
    
    private func createCheckboxes(preferences: [PreferencesModel]) {
        preferences.forEach {
            let checkboxView = CheckboxView()
            checkboxView.configure(title: $0.slug == "marketing-bink" ? "preferences_marketing_checkbox".localized : $0.label ?? "", columnName: $0.slug ?? "", columnKind: .add)
            
            checkboxView.delegate = self
            checkboxView.setValue(newValue: $0.value ?? "0")
            
            stackView.addArrangedSubview(checkboxView)
            checkboxes.append(checkboxView)
        }
    }
}

extension PreferencesViewController: CheckboxViewDelegate {
    func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FormField.ColumnKind) {
        guard let columnName = checkboxView.columnName else { return }
        
        let checkboxState = value == "true" ? "1" : "0"
        let dictionary = [columnName: checkboxState]
        
        viewModel.putPreferences(preferences: dictionary, onSuccess: {

        }) { (error) in
            checkboxView.toggleState()
        }
    }
}
