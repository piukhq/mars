//
//  UITableViewExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 03/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

public extension UITableView {
    func register<T: UITableViewCell>(_: T.Type, asNib: Bool = false) where T: ReusableView {
        if asNib {
            register(UINib(nibName: T.reuseIdentifier, bundle: nil),
                     forCellReuseIdentifier: T.reuseIdentifier)
        } else {
            register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    func dequeue<T: UITableViewCell>(indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}
