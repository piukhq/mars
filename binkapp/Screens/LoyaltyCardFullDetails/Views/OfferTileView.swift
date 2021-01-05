//
//  OfferTileView.swift
//  binkapp
//
//  Created by Dorin Pop on 11/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class OfferTileView: CustomView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var offerImageView: UIImageView!

    private let offerTileImage: CD_MembershipPlanImage

    init(offerTileImage: CD_MembershipPlanImage) {
        self.offerTileImage = offerTileImage
        super.init(frame: .zero)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        guard let imageUrl = offerTileImage.url else { return }
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        offerImageView.setImage(forPathType: .membershipPlanOfferTile(url: imageUrl))
        
        DispatchQueue.main.async {
            self.layer.applyDefaultBinkShadow()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        if let ctaUrl = offerTileImage.ctaUrl {
            let viewController = WebViewController(urlString: ctaUrl)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
}
