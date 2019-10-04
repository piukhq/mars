//
//  PaymentCardCell.swift
//  binkapp
//
//  Created by Dorin Pop on 01/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentCardCell: UITableViewCell {
    @IBOutlet private weak var paymentCardImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var switchButton: UISwitch!
    
    
    func configureUI(paymentCard: PaymentCardModel) {
//        paymentCardImageView.image = paymentCard.
//        titleLabel.text = title
//        subtitleLabel.text = subtitle
//        let binkGradientColor = colorWithGradient(frame: switchButton.frame, colors: [.binkPurple, .blueAccent])
//        switchButton.onTintColor = binkGradientColor
//        switchButton.tintColor = .gray//
    }
    
//    func colorWithGradient(frame: CGRect, colors: [UIColor]) -> UIColor {
//        
//        // create the background layer that will hold the gradient
//        let backgroundGradientLayer = CAGradientLayer()
//        backgroundGradientLayer.frame = frame
//         
//        // we create an array of CG colors from out UIColor array
//        let cgColors = colors.map({$0.cgColor})
//        
//        backgroundGradientLayer.colors = cgColors
//        
//        UIGraphicsBeginImageContext(backgroundGradientLayer.bounds.size)
//        backgroundGradientLayer.render(in: UIGraphicsGetCurrentContext()!)
//        let backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        
//        return UIColor(patternImage: backgroundColorImage)
//    }
}
