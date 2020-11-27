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

    var headerViewImageName: String? {
        switch dynamicAction.type {
        case .xmas:
            return "bink-logo-christmas"
        case .none:
            return nil
        }
    }

    var dynamicActionType: DynamicActionType? {
        return dynamicAction.type
    }

    func buttonHandler() {
        switch dynamicAction.event?.body?.cta?.action {
        case .zendeskContactUs:
            ZendeskTickets().launch()
        case .none:
            return
        }
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
        button.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)

        configureAnimationIfNecessary()
    }

    @objc private func buttonHandler() {
        viewModel.buttonHandler()
    }

    private func configureAnimationIfNecessary() {
        if viewModel.dynamicActionType == .xmas {
            CAEmitterLayer.addSnowfallLayer(to: view)
        }
    }
}

class DynamicActionHeaderView: CustomView {
    @IBOutlet private weak var imageView: UIImageView!

    func configureWithViewModel(_ viewModel: DynamicActionViewModel) {
        if let imageName = viewModel.headerViewImageName {
            imageView.image = UIImage(named: imageName)
        }
    }
}

extension CAEmitterLayer {
    static func addSnowfallLayer(to view: UIView) {
        let flakeEmitterCell = CAEmitterCell()
        flakeEmitterCell.contents = UIImage(named: "snowflake")?.cgImage
        flakeEmitterCell.scale = 0.06
        flakeEmitterCell.scaleRange = 0.3
        flakeEmitterCell.emissionRange = .pi
        flakeEmitterCell.lifetime = 20.0
        flakeEmitterCell.birthRate = 40
        flakeEmitterCell.velocity = -30
        flakeEmitterCell.velocityRange = -20
        flakeEmitterCell.yAcceleration = 30
        flakeEmitterCell.xAcceleration = 5
        flakeEmitterCell.spin = -0.5
        flakeEmitterCell.spinRange = 1.0

        let snowEmitterLayer = CAEmitterLayer()
        snowEmitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2.0, y: -50)
        snowEmitterLayer.emitterSize = CGSize(width: view.bounds.width, height: 0)
        snowEmitterLayer.emitterShape = CAEmitterLayerEmitterShape.line
        snowEmitterLayer.beginTime = CACurrentMediaTime()
        snowEmitterLayer.timeOffset = 10
        snowEmitterLayer.emitterCells = [flakeEmitterCell]
        view.layer.addSublayer(snowEmitterLayer)
    }
}
