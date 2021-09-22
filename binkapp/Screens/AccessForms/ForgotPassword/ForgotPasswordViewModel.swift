//
//  ForgotPasswordViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 29/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class ForgotPasswordViewModel: NSObject {
    let repository: ForgotPasswordRepository
//    var navigationController: UINavigationController?
    var email: String?
    var datasource: FormDataSource
    
    init(repository: ForgotPasswordRepository, datasource: FormDataSource) {
        self.repository = repository
        self.datasource = datasource
        super.init()
        datasource.delegate = self
    }
}

extension ForgotPasswordViewModel: FormDataSourceDelegate, CheckboxViewDelegate, FormCollectionViewCellDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
    
    func formDataSource(_ dataSource: FormDataSource, changed value: String?, for field: FormField) {
        email = value ?? ""
    }
    
    func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FormField.ColumnKind) {}
    func checkboxView(_ checkboxView: CheckboxView, didTapOn URL: URL) {}
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {}
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {}
    func formCollectionViewCellDidReceiveLoyaltyScannerButtonTap(_ cell: FormCollectionViewCell) {}
    func formCollectionViewCellDidReceivePaymentScannerButtonTap(_ cell: FormCollectionViewCell) {}
}
