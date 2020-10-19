//
//  HyperlinkLabel.swift
//  binkapp
//
//  Created by Sean Williams on 19/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

protocol HyperlinkTapDelegate: class {
    func hyperlinkWasTapped()
}

class HyperlinkLabel: UILabel {
    
    private var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    private var range: NSRange?
    weak var tapDelegate: HyperlinkTapDelegate?
    
    func configure(_ text: String, withHyperlink hyperlink: String) {
        isUserInteractionEnabled = true
        tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tapLabel(gesture:)))
        addGestureRecognizer(tapGesture)
        
        let attributedString = NSMutableAttributedString(string: text)
        range = (text as NSString).range(of: hyperlink)
        attributedString.addAttributes([.underlineStyle : NSUnderlineStyle.single.rawValue, .font: UIFont.linkUnderlined, .foregroundColor: UIColor.blueAccent], range: range!)
        attributedText = attributedString
    }
    
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
        // sort !!
        if gesture.didTapAttributedTextInLabel(label: self, inRange: range!) {
            print("Tapped contact us")
            tapDelegate?.hyperlinkWasTapped()
        } else {
            print("Tapped none")
        }
    }
}


extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        guard let attributedText = label.attributedText else { return false }
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)

        let mutableAttribString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttribString.addAttributes([.font: label.font!], range: NSRange(location: 0, length: attributedText.length))
        let textStorage = NSTextStorage(attributedString: mutableAttribString)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
