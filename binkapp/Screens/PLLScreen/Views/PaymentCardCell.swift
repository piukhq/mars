//
//  PaymentCardCell.swift
//  binkapp
//
//  Created by Dorin Pop on 01/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import AlamofireImage

protocol PaymentCardCellDelegate: class {
    func paymentCardCellDidToggleSwitch(_ paymentCell: PaymentCardCell, cardIndex: Int)
}

class PaymentCardCell: UITableViewCell {
    @IBOutlet private weak var paymentCardImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var switchButton: BinkSwitch!
    private weak var delegate: PaymentCardCellDelegate?
    private let activityIndicator = UIActivityIndicatorView()
    private var cardIndex = 0
    private var firsUse = true
        
    override func layoutSubviews() {
        activityIndicator.frame = paymentCardImageView.frame
        paymentCardImageView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func configureUI(membershipCard: CD_MembershipCard ,paymentCard: CD_PaymentCard, cardIndex: Int, delegate: PaymentCardCellDelegate, isAddJourney: Bool) {
        self.delegate = delegate
        self.cardIndex = cardIndex
        if let imageUrlString = paymentCard.imagesArray.first?.url {
            guard let imageUrl = URL(string: imageUrlString) else { return }
            paymentCardImageView?.af_setImage(withURL: imageUrl, placeholderImage: nil, filter: nil, progress: nil, progressQueue: .main, imageTransition: .noTransition, runImageTransitionIfCached: true, completion: { (response) in
                self.activityIndicator.removeFromSuperview()
            })
        }
        titleLabel.text = paymentCard.card?.nameOnCard
        subtitleLabel.text = "pll_screen_card_ending".localized + (paymentCard.card?.lastFour ?? "")
        if firsUse {
            switchButton.isOn = isAddJourney ? true : membershipCard.linkedPaymentCards.contains(paymentCard)
            firsUse = false
        }
    }
    
    // MARK: - Actions
    
    @IBAction func switchDidChangeValue(_ sender: BinkSwitch) {
        switchButton.isGradientVisible = sender.isOn
        delegate?.paymentCardCellDidToggleSwitch(self, cardIndex: cardIndex)
    }
}
