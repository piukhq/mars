//
//  PreferencesViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PreferencesViewController: BinkTrackableViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var errorLabel: UILabel!
    
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
        setScreenName(trackedScreen: .preferences)
        
        configureUI()
    }
    
    private func configureUI() {
        navigationItem.leftBarButtonItem?.title = nil
        
        titleLabel.text = "settings_row_preferences_title".localized
        titleLabel.font = UIFont.headline
        
        errorLabel.font = UIFont.bodyTextSmall
        errorLabel.textColor = .red
        
        let attributedString = NSMutableAttributedString(string: "preferences_screen_description".localized, attributes: [.font : UIFont.bodyTextLarge])
        let base: NSString = NSString(string: attributedString.string)
        let rewardsRange = base.range(of: "preferences_prompt_highlight_rewards".localized)
        let offersRange = base.range(of: "preferences_prompt_highlight_offers".localized)
        let updatesRange = base.range(of: "preferences_prompt_highlight_updates".localized)
        
        let attributes: [NSAttributedString.Key : Any]  = [.font : UIFont.subtitle]
        
        attributedString.addAttributes(attributes, range: rewardsRange)
        attributedString.addAttributes(attributes, range: offersRange)
        attributedString.addAttributes(attributes, range: updatesRange)
        
        descriptionLabel.attributedText = attributedString
        
        viewModel.getPreferences(onSuccess: { [weak self] (preferences) in
            self?.createCheckboxes(preferences: preferences)
        }) { [weak self] in
            self?.errorLabel.text = "preferences_retrieve_fail".localized
            self?.errorLabel.isHidden = false
        }
    }
    
    private func createCheckboxes(preferences: [PreferencesModel]) {
        preferences.forEach {
            let checkboxView = CheckboxView()
            let attributedString = $0.slug == "marketing-bink" ?
                NSMutableAttributedString(string: "preferences_marketing_checkbox".localized, attributes: [.font: UIFont.bodyTextSmall]) :
                NSMutableAttributedString(string: $0.label ?? "", attributes: [.font: UIFont.bodyTextSmall])
            checkboxView.configure(title: attributedString, columnName: $0.slug ?? "", columnKind: .add, delegate: self)
            
            checkboxView.setValue(newValue: $0.value ?? "0")
            
            stackView.addArrangedSubview(checkboxView)
            checkboxes.append(checkboxView)
        }
    }
}

extension PreferencesViewController: CheckboxViewDelegate {
    func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FormField.ColumnKind) {
        guard Current.apiManager.networkIsReachable else {
            viewModel.presentNoConnectivityPopup()
            checkboxView.toggleState()
            return
        }
        guard let columnName = checkboxView.columnName else { return }
        
        let checkboxState = value == "true" ? "1" : "0"
        let dictionary = [columnName: checkboxState]

        viewModel.putPreferences(preferences: dictionary, onSuccess: { [weak self] in
            self?.errorLabel.isHidden = true
        }) { [weak self] (error) in
            checkboxView.toggleState()
            self?.errorLabel.text = "preferences_update_fail".localized
            self?.errorLabel.isHidden = false
        }
    }
}
