//
//  WalletLoyaltyCardTableViewCell.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class WalletLoyaltyCardTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func draw(_ rect: CGRect) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Color Declarations
        let firstColor = UIColor(red: 0.135, green: 0.517, blue: 0.274, alpha: 1.000)
        let secondColor = UIColor(red: 0.660, green: 0.586, blue: 0.586, alpha: 1.000)
        
        //// Rectangle Drawing
        context.saveGState()
        context.translateBy(x: 120.76, y: 81.4)
        context.rotate(by: -45 * CGFloat.pi/180)
        
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 427.54, height: 333.64), cornerRadius: 8)
        secondColor.setFill()
        rectanglePath.fill()
        
        context.restoreGState()
        
    
        //// Rectangle 2 Drawing
        context.saveGState()
        context.translateBy(x: 134, y: 38.72)
        context.rotate(by: -20 * CGFloat.pi/180)
        
        let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 514.29, height: 370.52), cornerRadius: 8)
        firstColor.setFill()
        rectangle2Path.fill()
        
        context.restoreGState()
    }
}
