//
//  PLRStampsCell.swift
//  binkapp
//
//  Created by Nick Farrant on 14/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRStampsCell: PLRBaseCollectionViewCell {
    @IBOutlet private weak var stampsStackView: UIStackView!
    
    override func configureWithViewModel(_ viewModel: PLRCellViewModel) {
        super.configureWithViewModel(viewModel)
        configureStamps(viewModel: viewModel)
    }

    private func configureStamps(viewModel: PLRCellViewModel) {
        for index in 0..<viewModel.stampsAvailable {
            let stampView = PLRStampView()
            stampView.translatesAutoresizingMaskIntoConstraints = false
            stampsStackView.addArrangedSubview(stampView)
            stampView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            stampView.backgroundColor = stampColor(atIndex: index, viewModel: viewModel)
        }
    }

    private func stampColor(atIndex index: Int, viewModel: PLRCellViewModel) -> UIColor {
        if index < viewModel.stampsCollected {
            switch viewModel.voucherState {
            case .redeemed:
                return .blueAccent
            case .issued:
                return .greenOk
            case .inProgress:
                return .amberPending
            default:
                return .blueInactive
            }
        } else {
            return .grey10
        }
    }
}
