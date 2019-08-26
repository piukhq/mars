//
//  WalletLoyaltyCardTableViewCell.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import AlamofireImage

class WalletLoyaltyCardTableViewCell: UITableViewCell {
    @IBOutlet private weak var cardIconImage: UIImageView!
    @IBOutlet private weak var cardNameLabel: UILabel!
    @IBOutlet private weak var cardValuePointsLabel: UILabel!
    @IBOutlet private weak var cardLinkStatusLabel: UILabel!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var cardLinkStatusImage: UIImageView!
    
    var firstColorHex: String = "#D3D3D3"
    var secondColorHex: String = "#888888"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
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
    
    
    func configureUIWithMembershipCard(card: MembershipCardModel, andMemebershipPlan plan: MembershipPlanModel) {
        if let imageStringURL = plan.images?.first(where: {($0.type == 3)})?.url {
            let imageURL = URL(string: imageStringURL)!
            cardIconImage.af_setImage(withURL: imageURL)
        }
        
        firstColorHex = card.card?.colour ?? ""
        cardNameLabel.text = plan.account?.companyName
        cardNameLabel.font = UIFont.subtitle
        cardValuePointsLabel.font = UIFont.subtitle
        
        switch card.status?.state {
        case "failed":
            logInButton.isHidden = false
            logInButton.imageView?.contentMode = .scaleAspectFill
            cardValuePointsLabel.isHidden = true
            break
        case "pending":
            cardValuePointsLabel.text = card.status?.state

            break
        case "authorised":
            if plan.featureSet?.cardType == 2 {
                cardLinkStatusImage.image = UIImage(imageLiteralResourceName: "linked")
                cardLinkStatusImage.isHidden = false
                cardLinkStatusLabel.text = NSLocalizedString("card_linked_status", comment: "")
                cardLinkStatusLabel.isHidden = false
            }
            if plan.featureSet?.hasPoints == true {
                let prefix = card.balances?[0].prefix ?? ""
                let suffix = card.balances?[0].suffix ?? ""
                if let balanceValue = card.balances?[0].value {
                    cardValuePointsLabel.text = prefix + "\(balanceValue)" + "\n" + suffix
                }
            } else {
                cardValuePointsLabel.isHidden = true
            }
        case "unauthorised":
            if plan.featureSet?.cardType == 2 {
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
   
    @IBAction func logInButtonTapped(_ sender: Any) {
        //TODO: Add implementation
    }
}
