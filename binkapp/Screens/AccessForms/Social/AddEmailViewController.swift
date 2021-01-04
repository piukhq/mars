//
//  AddEmailViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 03/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class AddEmailViewController: BaseFormViewController {
    typealias AddEmailCompletion = (FacebookRequest) -> Void

    private lazy var continueButton: BinkButton = {
        return BinkButton(type: .gradient, title: "continue_button_title".localized, enabled: false) { [weak self] in
            self?.continueButtonTapped()
        }
    }()

    private var request: FacebookRequest
    private let completion: AddEmailCompletion
        
    init(request: FacebookRequest, completion: @escaping AddEmailCompletion) {
        self.request = request
        self.completion = completion
        super.init(title: "add_email_title".localized, description: "add_email_subtitle".localized, dataSource: FormDataSource(accessForm: .addEmail))
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        footerButtons = [continueButton]
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        continueButton.enabled = fullFormIsValid
    }
    
    private func continueButtonTapped() {
        let fields = dataSource.currentFieldValues()
        request.email = fields["email"]
        completion(request)
    }
}

extension AddEmailViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
}

extension AddEmailViewController: FormCollectionViewCellDelegate {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {}
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {}
}
