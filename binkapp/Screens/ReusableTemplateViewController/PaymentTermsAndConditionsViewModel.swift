//
//  PaymentTermsAndConditionsViewModel.swift
//  binkapp
//
//  Created by Dorin Pop on 17/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentTermsAndConditionsViewModel: ReusableModalViewModel {
    override var primaryButtonTitle: String? {
        return "i_accept".localized
    }
    
    override var secondaryButtonTitle: String? {
        return "i_decline".localized
    }
        
    override func mainButtonWasTapped(completion: (() -> Void)? = nil) {
        Current.navigate.close(completion: completion)
    }
    
    override func secondaryButtonWasTapped() {
        Current.navigate.close()
    }
}
