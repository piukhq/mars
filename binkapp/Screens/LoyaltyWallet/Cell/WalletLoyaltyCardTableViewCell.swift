//
//  WalletLoyaltyCardTableViewCell.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import AlamofireImage

enum SwipeMode {
    case unset // centered
    case delete // right to left
    case barcode // left to right
}

enum SwipeState {
    case closed
    case peek
    case expanded
}

enum CellAction {
    case barcode
    case delete
    case login
}

protocol WalletLoyaltyCardCollectionViewCellDelegate: NSObject {
    func cellSwipeBegan(cell: WalletLoyaltyCardCollectionViewCell)
    func cellDidFullySwipe(action: SwipeMode?, cell: WalletLoyaltyCardCollectionViewCell)
    func cellPerform(action: CellAction, cell: WalletLoyaltyCardCollectionViewCell)
}

class WalletLoyaltyCardCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    @IBOutlet private weak var cardIconImage: UIImageView!
    @IBOutlet private weak var cardNameLabel: UILabel!
    @IBOutlet private weak var cardValuePointsLabel: UILabel!
    @IBOutlet private weak var cardValueSuffixLabel: UILabel!
    @IBOutlet private weak var cardLinkStatusLabel: UILabel!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var cardLinkStatusImage: UIImageView!
    @IBOutlet weak var cardContainer: RectangleView!
    @IBOutlet weak var cardContainerCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var barcodeButton: UIButton!
    
    weak var delegate: WalletLoyaltyCardCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGestureRecognizer()
    }
    
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupGestureRecognizer() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: .handlePan)
        gestureRecognizer.delegate = self
        cardContainer.addGestureRecognizer(gestureRecognizer)
    }
    
    private var swipeMode: SwipeMode? {
        didSet {
            guard let mode = swipeMode, mode != oldValue else { return }
            updateColor(with: mode)
            updateButtonState(with: mode)
        }
    }
    
    private (set) var swipeState: SwipeState?
    
    private func setupShadow() {
        cardContainer.layer.cornerRadius = 8
        cardContainer.layer.masksToBounds = true
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.3
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        clipsToBounds = false
    }
    
    func configureUIWithMembershipCard(card: MembershipCardModel, andMemebershipPlan plan: MembershipPlanModel, delegate: WalletLoyaltyCardCollectionViewCellDelegate) {
        
        self.delegate = delegate
        
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
    
    var gradientLayer: CAGradientLayer?
    
    private func updateColor(with swipeMode: SwipeMode) {
        let firstColor, secondColor: UIColor
        
        switch swipeMode {
        case .delete:
            firstColor = UIColor(red: 1, green: 107/255.0, blue: 54/255.0, alpha: 1.0)
            secondColor = UIColor(red: 235/255.0, green: 0, blue: 27/255.0, alpha: 1.0)
            processGradient(firstColor, secondColor)
        case .barcode:
            firstColor = UIColor(red: 180/255.0, green: 111/255.0, blue: 234/255.0, alpha: 1.0)
            secondColor = UIColor(red: 67/255.0, green: 113/255.0, blue: 254/255.0, alpha: 1.0)
            processGradient(firstColor, secondColor)
        case .unset:
            print()
        }
    }
    
    private func updateButtonState(with swipeMode: SwipeMode) {
        switch swipeMode {
        case .delete:
            barcodeButton.isHidden = true
            deleteButton.isHidden = false
        case .barcode:
            barcodeButton.isHidden = false
            deleteButton.isHidden = true
        case .unset:
            barcodeButton.isHidden = true
            deleteButton.isHidden = true
        }
    }
    
    private func processGradient(_ firstColor: UIColor, _ secondColor: UIColor) {
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            contentView.layer.insertSublayer(gradientLayer!, at: 0)
        }
        
        gradientLayer?.frame = bounds
        gradientLayer?.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer?.locations = [0.0, 1.0]
        gradientLayer?.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer?.endPoint = CGPoint(x: 0.0, y: 0.0)
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }

        return abs((pan.velocity(in: pan.view)).x) > abs((pan.velocity(in: pan.view)).y)
    }
   
    @IBAction func logInButtonTapped(_ sender: Any) {
        //TODO: Add implementation
        delegate?.cellPerform(action: .login, cell: self)
    }
    
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        delegate?.cellPerform(action: .delete, cell: self)
    }
    
    @IBAction func barcodeButtonTapped(_ sender: Any) {
        delegate?.cellPerform(action: .barcode, cell: self)
    }
    
    var startingOffset: CGFloat = 0
    
    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        
        let translationX = startingOffset + gestureRecognizer.translation(in: view.superview).x * 1.3
        
        if gestureRecognizer.state == .began {
            // Save the view's original position.
            swipeMode = .unset
            delegate?.cellSwipeBegan(cell: self)
        }
        
        if gestureRecognizer.state == .changed {
            // Save the view's original position.
            
            swipeMode = translationX > 0 ? .barcode : .delete
            var constant: CGFloat = translationX
            var maxValue: CGFloat?
            var minValue: CGFloat?
            
            if swipeMode == .barcode {
                maxValue = view.frame.size.width * 0.9
                minValue = 0
                
                let limitToUpper = min(translationX, maxValue!)
                constant = max(limitToUpper, minValue!)
            } else if swipeMode == .delete {
                maxValue = -(view.frame.size.width * 0.5)
                minValue = 0
                
                let limitToUpper = max(translationX, maxValue!)
                constant = min(limitToUpper, minValue!)
            }
            
            cardContainerCenterXConstraint.constant = constant
        }
        
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            
            // Get percentage through
            
            let percentage = abs(translationX) / view.frame.size.width
            
            if percentage < 0.3 {
                swipeMode = .unset
                set(to: .closed, as: swipeMode)
            } else if percentage < 0.6 {
                set(to: .peek, as: swipeMode)
            } else {
                // Commit action
                set(to: .expanded, as: swipeMode)
                delegate?.cellDidFullySwipe(action: swipeMode, cell: self)
            }
        }
    }
    
    func set(to state: SwipeState, as type: SwipeMode? = nil) {
        swipeState = state
        let width = cardContainer.frame.size.width
        let constant: CGFloat
        
        switch state {
        case .closed:
            constant = 0
        case .peek:
            
            guard let type = type else { return }
            
            if type == .barcode {
                constant = width * 0.3
            } else {
                constant = -(width * 0.3)
            }
        case .expanded:
            
            guard let type = type else { return }
            
            if type == .barcode {
                constant = width
            } else {
                constant = -(width * 0.5)
            }
        }
        
        startingOffset = constant
        
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.cardContainerCenterXConstraint.constant = constant
            self?.layoutIfNeeded()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        set(to: .closed)
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
