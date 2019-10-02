//
//  WalletLoyaltyCardCollectionViewCell.swift
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
    @IBOutlet private weak var logInButton: CardAlertView!
    @IBOutlet private weak var cardLinkStatusImage: UIImageView!
    @IBOutlet weak var cardContainer: RectangleView!
    @IBOutlet weak var cardContainerCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var barcodeButton: UIButton!

    private var viewModel: WalletLoyaltyCardCellViewModel!
    weak var delegate: WalletLoyaltyCardCollectionViewCellDelegate?

    var gradientLayer: CAGradientLayer?
    var startingOffset: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGestureRecognizer()
        setupTheming()
    }
    
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        set(to: .closed)
        cardIconImage.image = nil
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
    
    private func setupTheming() {
        [cardNameLabel, cardValuePointsLabel, cardValueSuffixLabel, cardLinkStatusLabel].forEach {
            $0?.textColor = .white
        }

        cardNameLabel.font = .subtitle
        cardValuePointsLabel.font = .pointsValue
        cardValueSuffixLabel.font = .navbarHeaderLine2
        cardLinkStatusLabel.font = .statusLabel
    }
    
    func configureUIWithViewModel(viewModel: WalletLoyaltyCardCellViewModel, delegate: WalletLoyaltyCardCollectionViewCellDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        
        guard let plan = viewModel.membershipPlan else { return }

        /// Brand icon
        if let iconImage = plan.firstIconImage(),
            let urlString = iconImage.url,
            let imageURL = URL(string: urlString) {
            cardIconImage.af_setImage(withURL: imageURL)
        }

        /// Brand colours
        cardContainer.firstColorHex = viewModel.brandColorHex ?? ""

        /// Brand name
        cardNameLabel.text = plan.account?.companyName
        
        /// Link Status
        cardLinkStatusLabel.text = viewModel.linkStatusText
        cardLinkStatusImage.image = UIImage(named: viewModel.linkStatusImageName)
        cardLinkStatusImage.isHidden = !viewModel.shouldShowLinkStatus
        cardLinkStatusLabel.isHidden = !viewModel.shouldShowLinkStatus
        
        /// Login Button
        logInButton.configureForType(.loyaltyLogIn) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.cellPerform(action: .login, cell: strongSelf)
        }
        logInButton.isHidden = !viewModel.shouldShowLoginButton

        /// Card Value
        cardValuePointsLabel.text = viewModel.pointsValueText
        cardValueSuffixLabel.text = viewModel.pointsValueSuffixText
        cardValuePointsLabel.isHidden = !viewModel.shouldShowPointsValueLabels
        cardValueSuffixLabel.isHidden = !viewModel.shouldShowPointsValueLabels
    }

}

private extension Selector {
    static let handlePan = #selector(WalletLoyaltyCardCollectionViewCell.handlePan(gestureRecognizer:))
}

// MARK: - Swiping

extension WalletLoyaltyCardCollectionViewCell {
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
}
