//
//  PaymentTermsAndConditionsViewModel.swift
//  binkapp
//
//  Created by Dorin Pop on 17/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentTermsAndConditionsViewModel: ReusableModalViewModel {
    
    override var mainButtonTitle: String? {
        return "accept".localized
    }
    
    override var secondaryButtonTitle: String? {
        return "decline".localized
    }
    
    override func mainButtonWasTapped() {
        router.displaySimplePopup(title: "error".localized, message: "to_be_implemented_message".localized)
    }
    
    override func secondaryButtonWasTapped() {
        router.popViewController()
    }
}
