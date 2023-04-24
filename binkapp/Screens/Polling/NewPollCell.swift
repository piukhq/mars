//
//  NewPollCell.swift
//  binkapp
//
//  Created by Ricardo Silva on 14/04/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI
import UIKit

class NewPollCell: UICollectionViewCell {
    static var reuseIdentifier = "NewPollCell"
    
    lazy var host: UIHostingController = {
        return UIHostingController(rootView: NewPollCellSwiftUIView(viewModel: NewPollCellViewModel()))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupView() {
        host.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(host.view)
        
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            host.view.widthAnchor.constraint(equalToConstant: contentView.frame.width)
            //host.view.heightAnchor.constraint(equalToConstant: 120.0)
        ])
    }
}
