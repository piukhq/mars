//
//  DynamicActionViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 26/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

struct DynamicActionViewModel {
    private let dynamicAction: DynamicAction

    init(dynamicAction: DynamicAction) {
        self.dynamicAction = dynamicAction
    }

    var titleString: String? {
        return dynamicAction.event?.body?.title
    }

    var descriptionString: String? {
        return dynamicAction.event?.body?.description
    }

    var buttonTitle: String? {
        return dynamicAction.event?.body?.cta?.title
    }
}

class DynamicActionViewController: BinkViewController {
    @IBOutlet private weak var headerView: DynamicActionHeaderView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var button: BinkGradientButton!

    private let viewModel: DynamicActionViewModel

    init(viewModel: DynamicActionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        headerView.configureWithViewModel(viewModel)
        titleLabel.text = viewModel.titleString
        titleLabel.font = .headline
        descriptionLabel.text = viewModel.descriptionString
        descriptionLabel.font = .bodyTextLarge
        button.setTitle(viewModel.buttonTitle, for: .normal)
    }
}

class DynamicActionHeaderView: CustomView {
    @IBOutlet private weak var imageView: UIImageView!

    func configureWithViewModel(_ viewModel: DynamicActionViewModel) {
        imageView.image = UIImage(named: "bink-logo")
    }
}
