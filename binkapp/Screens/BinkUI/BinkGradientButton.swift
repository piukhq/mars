//
//  BinkGradientButton.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class BinkGradientButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    func configureUI() {
        self.setGradientBackground(firstColor: UIColor(red: 180/255, green: 111/255, blue: 234/255, alpha: 1), secondColor: UIColor.blueAccent)
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
        
        // add the border to subview
        let borderView = UIView(frame: self.bounds)
        
        borderView.layer.shadowColor = UIColor.black.cgColor
        borderView.layer.shadowOffset = CGSize(width: 3, height: 8)
        borderView.layer.shadowOpacity = 0.7
        borderView.layer.shadowRadius = 8.0
        
        borderView.layer.masksToBounds = true
        self.addSubview(borderView)
    }
}
