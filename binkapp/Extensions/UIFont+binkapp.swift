//
//  UIFont + binkapp.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    class var headline: UIFont {
        return UIFont(name: "NunitoSans-ExtraBold", size: 25.0) ?? UIFont()
    }
    
    class var navbarHeaderLine1: UIFont {
        return UIFont(name: "NunitoSans-ExtraBold", size: 18.0) ?? UIFont()
    }
    
    class var subtitle: UIFont {
        return UIFont(name: "NunitoSans-ExtraBold", size: 18.0) ?? UIFont()
    }
    
    class var pointsValue: UIFont {
        return UIFont(name: "NunitoSans-ExtraBold", size: 17.0) ?? UIFont()
    }
    
    class var buttonText: UIFont {
        return UIFont(name: "NunitoSans-Bold", size: 18.0) ?? UIFont()
    }

    class var miniButtonText: UIFont {
        return UIFont(name: "NunitoSans-Bold", size: 14.0) ?? UIFont()
    }
    
    class var linkTextButtonNormal: UIFont {
        return UIFont(name: "NunitoSans-SemiBold", size: 18.0) ?? UIFont()
    }
    
    class var linkUnderlined: UIFont {
        return UIFont(name: "NunitoSans-SemiBold", size: 18.0) ?? UIFont()
    }
    
    class var textFieldDescription: UIFont {
        return UIFont(name: "NunitoSans-Regular", size: 18.0) ?? UIFont()
    }
    
    class var textFieldInput: UIFont {
        return UIFont(name: "NunitoSans-Light", size: 18.0) ?? UIFont()
    }
    
    class var bodyTextLarge: UIFont {
        return UIFont(name: "NunitoSans-Light", size: 18.0) ?? UIFont()
    }

    class var alertText: UIFont {
        return UIFont(name: "NunitoSans-ExtraBold", size: 17.0) ?? UIFont()
    }
    
    class var textFieldLabel: UIFont {
        return UIFont(name: "NunitoSans-ExtraBold", size: 15.0) ?? UIFont()
    }

    class var statusLabel: UIFont {
        return UIFont(name: "NunitoSans-SemiBold", size: 15.0) ?? UIFont()
    }

    class var navbarHeaderLine2: UIFont {
        return UIFont(name: "NunitoSans-Regular", size: 15.0) ?? UIFont()
    }
    
    class var textFieldExplainer: UIFont {
        return UIFont(name: "NunitoSans-Regular", size: 14.0) ?? UIFont()
    }
    
    class var checkboxText: UIFont {
        return UIFont(name: "NunitoSans-SemiBold", size: 14.0) ?? UIFont()
    }
    
    class var textFieldError: UIFont {
        return UIFont(name: "NunitoSans-Regular", size: 14.0) ?? UIFont()
    }
    
    class var bodyTextSmall: UIFont {
        return UIFont(name: "NunitoSans-Light", size: 14.0) ?? UIFont()
    }

    class var redactedCardNumberPrefix: UIFont {
        return UIFont(name: "NunitoSans-SemiBold", size: 10.0) ?? UIFont()
    }
    
    class var tabBar: UIFont {
        return UIFont(name: "NunitoSans-Regular", size: 12.0) ?? UIFont()
    }
    
    class var navBar: UIFont {
        return UIFont(name: "NunitoSans-ExtraBold", size: 18.0) ?? UIFont()
    }
    
    class var walletPromptTitleSmall: UIFont {
        return UIFont(name: "NunitoSans-Bold", size: 16.0) ?? UIFont()
    }
    
    class var walletPromptBodySmall: UIFont {
        return UIFont(name: "NunitoSans-Regular", size: 14.0) ?? UIFont()
    }
}
