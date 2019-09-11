//
//  WalletLoyaltyCardTableViewCell.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import AlamofireImage

class WalletLoyaltyCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var cardIconImage: UIImageView!
    @IBOutlet private weak var cardNameLabel: UILabel!
    @IBOutlet private weak var cardValuePointsLabel: UILabel!
    @IBOutlet private weak var cardValueSuffixLabel: UILabel!
    @IBOutlet private weak var cardLinkStatusLabel: UILabel!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var cardLinkStatusImage: UIImageView!
    @IBOutlet weak var cardContainer: RectangleView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        setupGestureRecognizer()
    }
    
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupGestureRecognizer() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: .handlePan)
        cardContainer.addGestureRecognizer(gestureRecognizer)
    }
    
    private func setupShadow() {
        cardContainer.layer.cornerRadius = 8
        cardContainer.layer.masksToBounds = true
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.3
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        clipsToBounds = false
    }
    
    func configureUIWithMembershipCard(card: MembershipCardModel, andMemebershipPlan plan: MembershipPlanModel) {
        
        if let imageStringURL = plan.images?.first(where: {($0.type == 3)})?.url {
            let imageURL = URL(string: imageStringURL)!
            cardIconImage.af_setImage(withURL: imageURL)
        }

        cardContainer.firstColorHex = card.card?.colour ?? ""
        cardNameLabel.text = plan.account?.companyName
        cardNameLabel.font = UIFont.subtitle
        cardValuePointsLabel.font = UIFont.pointsValue

        switch card.status?.state {
        case .failed?:
            logInButton.isHidden = false
//            logInButton.imageView?.contentMode = .scaleAspectFill
            cardValuePointsLabel.isHidden = true
            cardValueSuffixLabel.isHidden = true
            break
        case .pending?:
            cardValuePointsLabel.text = card.status?.state?.rawValue

            break
        case .authorised?:
            if plan.featureSet?.cardType == .link {
                cardLinkStatusImage.image = UIImage(imageLiteralResourceName: "linked")
                cardLinkStatusImage.isHidden = false
                cardLinkStatusLabel.text = "card_linked_status".localized
                cardLinkStatusLabel.isHidden = false
            }
            if plan.featureSet?.hasPoints == true {
                if let balanceValue = card.balances?[0].value {
                    let attributedPrefix = NSMutableAttributedString(string: card.balances?[0].prefix ?? "")
                    let attributedSuffix = NSMutableAttributedString(string: (card.balances?[0].suffix ?? ""), attributes:[NSAttributedString.Key.font: UIFont.navbarHeaderLine2])
                    let attributedValue = NSMutableAttributedString(string: String(balanceValue))
                    let attributedLabelText = NSMutableAttributedString()
                    attributedLabelText.append(attributedPrefix)
                    attributedLabelText.append(attributedValue)
                    cardValuePointsLabel.attributedText = attributedLabelText
                    cardValueSuffixLabel.attributedText = attributedSuffix
                }
            } else {
                cardValuePointsLabel.superview?.isHidden = true
            }
        case .unauthorised?:
            if plan.featureSet?.cardType == .link {
                cardLinkStatusLabel.isHidden = false
                cardLinkStatusImage.isHidden = false
                cardLinkStatusLabel.text = NSLocalizedString("card_can_not_link_status", comment: "")
                cardLinkStatusImage.image = UIImage(imageLiteralResourceName: "unlinked")
            }
            break
        default:
            break
        }
    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
//
//        return abs((pan.velocity(in: pan.view)).x) > abs((pan.velocity(in: pan.view)).y)
//    }
   
    @IBAction func logInButtonTapped(_ sender: Any) {
        //TODO: Add implementation
    }
    
    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
//        guard gestureRecognizer.view != nil else {return}
//        let piece = gestureRecognizer.view!
//        // Get the changes in the X and Y directions relative to
//        // the superview's coordinate space.
//        let translation = gestureRecognizer.translation(in: piece.superview)
//        if gestureRecognizer.state == .began {
//            // Save the view's original position.
//            self.initialCenter = piece.center
//        }
//        // Update the position for the .began, .changed, and .ended states
//        if gestureRecognizer.state != .cancelled {
//            // Add the X and Y translation to the view's original position.
//            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
//            piece.center = newCenter
//        }
//        else {
//            // On cancellation, return the piece to its original location.
//            piece.center = initialCenter
//        }
    }
}

private extension Selector {
    static let handlePan = #selector(WalletLoyaltyCardCollectionViewCell.handlePan(gestureRecognizer:))
}

class RectangleView: UIView {
    
    var firstColorHex: String = "#D3D3D3" {
        didSet {
            setNeedsDisplay()
        }
    }
    var secondColorHex: String = "#888888"
    
    override func draw(_ rect: CGRect) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Color Declarations
        let firstColor = UIColor(hexString: firstColorHex)
        let secondColor = UIColor(hexString: secondColorHex)
        
        //// Rectangle Drawing
        context.saveGState()
        context.translateBy(x: 120.76, y: 81.4)
        context.rotate(by: -45 * CGFloat.pi/180)
        
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 427.54, height: 333.64), cornerRadius: 8)
        secondColor.setFill()
        rectanglePath.fill()
        
        context.restoreGState()
        
        //// Rectangle 2 Drawing
        context.saveGState()
        context.translateBy(x: 134, y: 38.72)
        context.rotate(by: -20 * CGFloat.pi/180)
        
        let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 514.29, height: 370.52), cornerRadius: 8)
        firstColor.setFill()
        rectangle2Path.fill()
        
        context.restoreGState()
    }
}
