//
//  HyperlinkLabel.swift
//  binkapp
//
//  Created by Sean Williams on 19/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

protocol HyperlinkLabelDelegate: AnyObject {
    func hyperlinkLabelWasTapped(_ hyperlinkLabel: HyperlinkLabel)
}

class HyperlinkLabel: UILabel {
    private let tapGesture = UITapGestureRecognizer()
    private var range: NSRange?
    private weak var delegate: HyperlinkLabelDelegate?
    
    func configure(_ text: String, withHyperlink hyperlink: String, delegate: HyperlinkLabelDelegate?) {
        isUserInteractionEnabled = true
        tapGesture.addTarget(self, action: #selector(tapLabel(gesture:)))
        addGestureRecognizer(tapGesture)
        self.delegate = delegate
        let attributedString = NSMutableAttributedString(string: text)
        range = (text as NSString).range(of: hyperlink)
        if let range = range {
            attributedString.addAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.linkUnderlined, .foregroundColor: UIColor.binkBlue], range: range)
            attributedText = attributedString
        }
    }
    
    @objc private func tapLabel(gesture: UITapGestureRecognizer) {
        if let range = range {
            if gesture.didTapAttributedTextInLabel(label: self, inRange: range) {
                delegate?.hyperlinkLabelWasTapped(self)
            }
        }
    }
}


extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        guard let attributedText = label.attributedText else { return false }
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)

        let mutableAttribString = NSMutableAttributedString(attributedString: attributedText)
        guard let font = label.font else { return false }
        mutableAttribString.addAttributes([.font: font], range: NSRange(location: 0, length: attributedText.length))
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
