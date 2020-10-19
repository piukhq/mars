//
//  HyperlinkLabel.swift
//  binkapp
//
//  Created by Sean Williams on 19/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class HyperlinkLabel: UILabel {
    
    private func configure() {
        self.isUserInteractionEnabled = true
//        let gesture = UITapGestureRecognizer()
//        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLabel)))
    }
    
    
}


//extension UITapGestureRecognizer {
//
//    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
//        let layoutManager = NSLayoutManager()
//        let textContainer = NSTextContainer(size: CGSize.zero)
//
//        let mutableAttribString = NSMutableAttributedString(attributedString: label.attributedText!)
//            // Add font so the correct range is returned for multi-line labels
////        let contactUsRange = (description as NSString).range(of: "Contact us")
//        mutableAttribString.addAttributes([.font: UIFont.linkUnderlined], range: NSRange(location: 0, length: label.attributedText!.length))
////        mutableAttribString.addAttributes([.underlineStyle : NSUnderlineStyle.single.rawValue, .font: UIFont.linkUnderlined, .foregroundColor: UIColor.blueAccent], range: contactUsRange)
//
//        let textStorage = NSTextStorage(attributedString: mutableAttribString)
//
//        layoutManager.addTextContainer(textContainer)
//        textStorage.addLayoutManager(layoutManager)
//
//        textContainer.lineFragmentPadding = 0.0
//        textContainer.lineBreakMode = label.lineBreakMode
//        textContainer.maximumNumberOfLines = label.numberOfLines
//        let labelSize = label.bounds.size
//        textContainer.size = labelSize
//
//        let locationOfTouchInLabel = self.location(in: label)
//        let textBoundingBox = layoutManager.usedRect(for: textContainer)
//        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
//        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
//        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
//        return NSLocationInRange(indexOfCharacter, targetRange)
//    }
//
//}
