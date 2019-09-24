//
//  UICollectionViewExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 24/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

extension UICollectionView {
    func registerCellForClass(_ cellClass: AnyClass, asNib: Bool = false) {
        if asNib {
            register(UINib(nibName: String(describing: cellClass), bundle: nil), forCellWithReuseIdentifier: String(describing: cellClass))
        } else {
            register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
        }
    }

    func dequeueReusableCellWithClass<T>(_ type: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Tried to dequeue unavailable cell type")
        }
        return cell
    }
}
