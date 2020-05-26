//
//  LeftAlignedCollectionViewLayout.swift
//  binkapp
//
//  Created by Nick Farrant on 20/05/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

// https://stackoverflow.com/a/36016798
// Layout code snippet taken from widely used Stack Overflow answer linked above.
class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        return attributes
    }
}
