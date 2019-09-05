//
//  UITableViewExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 03/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

extension UITableView {
    func registerCellForClass(_ cellClass: AnyClass, asNib: Bool = false) {
        if asNib {
            register(UINib(nibName: String(describing: cellClass), bundle: nil), forCellReuseIdentifier: String(describing: cellClass))
        } else {
            register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
        }
    }
    
    func dequeueReusableCellWithClass<T>(_ type: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Tried to dequeue unavailable cell type")
        }
        return cell
    }
}
