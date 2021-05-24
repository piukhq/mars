//
//  WalletLoyaltyCardCollectionViewCell.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

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

protocol WalletLoyaltyCardCollectionViewCellDelegate: AnyObject {
    func cellSwipeBegan(cell: WalletLoyaltyCardCollectionViewCell)
    func cellDidFullySwipe(action: SwipeMode?, cell: WalletLoyaltyCardCollectionViewCell)
    func cellPerform(action: CellAction, cell: WalletLoyaltyCardCollectionViewCell)
}

class WalletLoyaltyCardCollectionViewCell: WalletCardCollectionViewCell, UIGestureRecognizerDelegate {
    @IBOutlet private weak var cardIconImageView: UIImageView!
    @IBOutlet private weak var cardNameLabel: UILabel!
    @IBOutlet private weak var cardValuePointsLabel: UILabel!
    @IBOutlet private weak var cardValueSuffixLabel: UILabel!
    @IBOutlet private weak var cardLinkStatusLabel: UILabel!
    @IBOutlet private weak var logInAlert: CardAlertView!
    @IBOutlet private weak var cardLinkStatusImage: UIImageView!
    @IBOutlet private weak var cardContainerCenterXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var barcodeButton: UIButton!
    @IBOutlet private weak var rectangleView: RectangleView!
    
    private lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    private lazy var height: NSLayoutConstraint = {
        let height = contentView.heightAnchor.constraint(equalToConstant: bounds.size.height)
        height.isActive = true
        return height
    }()
    
    private var viewModel: WalletLoyaltyCardCellViewModel!
    private weak var delegate: WalletLoyaltyCardCollectionViewCellDelegate?
    
    private var swipeGradientLayer: CAGradientLayer?
    private var startingOffset: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
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
        set(to: .closed, animated: false)
        cardIconImageView.image = nil
    }
    
    private func setupGestureRecognizer() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: .handlePan)
        gestureRecognizer.delegate = self
        rectangleView.addGestureRecognizer(gestureRecognizer)
    }
    
    private var swipeMode: SwipeMode? {
        didSet {
            guard let mode = swipeMode, mode != oldValue else { return }
            updateColor(with: mode)
            updateButtonState(with: mode)
        }
    }
    private (set) var swipeState: SwipeState?
    
    private func setupTheming() {
        [cardNameLabel, cardValuePointsLabel, cardValueSuffixLabel, cardLinkStatusLabel].forEach {
            $0?.textColor = .white
        }
        
        cardNameLabel.font = .subtitle
        cardValuePointsLabel.font = .pointsValue
        cardValueSuffixLabel.font = .navbarHeaderLine2
        cardLinkStatusLabel.font = .statusLabel
    }
    
    func configureUIWithViewModel(viewModel: WalletLoyaltyCardCellViewModel, indexPath: IndexPath, delegate: WalletLoyaltyCardCollectionViewCellDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        tag = indexPath.row
        
        guard let plan = viewModel.membershipPlan else { return }
        ImageService.getImage(forPathType: .membershipPlanIcon(plan: plan), traitCollection: traitCollection) { image in
            if self.tag == indexPath.row {
                self.cardIconImageView.image = image
            }
        }
        
        /// Brand colours
        let primaryBrandColor = UIColor(hexString: viewModel.brandColorHex ?? "")
        rectangleView.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
        rectangleView.firstColor = primaryBrandColor
        rectangleView.secondColor = plan.secondaryBrandColor
        
        /// Brand name
        cardNameLabel.text = plan.account?.companyName
        
        /// Link Status
        cardLinkStatusLabel.text = viewModel.linkStatusText
        cardLinkStatusImage.image = UIImage(named: viewModel.linkStatusImageName)
        cardLinkStatusImage.isHidden = !viewModel.shouldShowLinkImage
        cardLinkStatusLabel.isHidden = !viewModel.shouldShowLinkStatus
        
        /// Login Button will not be visible for the MVP and waiting for the correct reason codes/state to display it
        //        logInAlert.configureForType(.loyaltyLogIn) { [weak self] in
        //            guard let self = self else { return }
        //            self.delegate?.cellPerform(action: .login, cell: self)
        //        }
        logInAlert.isHidden = true
        
        /// Card Value
        cardValuePointsLabel.text = viewModel.pointsValueText
        cardValueSuffixLabel.text = viewModel.pointsValueSuffixText
        cardValuePointsLabel.isHidden = !viewModel.shouldShowPointsValueLabel
        cardValueSuffixLabel.isHidden = !viewModel.shouldShowPointsSuffixLabel
        
        [cardNameLabel, cardValuePointsLabel, cardLinkStatusLabel, cardValueSuffixLabel].forEach {
            $0.textColor = primaryBrandColor.isLight(threshold: 0.8) ? .black : .white
        }
        
        containerView.backgroundColor = .clear
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        height.constant = bounds.size.height
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: targetSize.height))
    }
}

private extension Selector {
    static let handlePan = #selector(WalletLoyaltyCardCollectionViewCell.handlePan(gestureRecognizer:))
}

// MARK: - Swiping

extension WalletLoyaltyCardCollectionViewCell {
    private func updateColor(with swipeMode: SwipeMode) {
        switch swipeMode {
        case .delete:
            processGradient(.deleteSwipeGradientLeft, .deleteSwipeGradientRight)
        case .barcode:
            processGradient(.binkGradientBlueLeft, .binkGradientBlueRight)
        case .unset:
            break
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
        if swipeGradientLayer == nil {
            swipeGradientLayer = CAGradientLayer()
            guard let gradientLayer = swipeGradientLayer else { return }
            contentView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        swipeGradientLayer?.frame = bounds
        swipeGradientLayer?.colors = [firstColor.cgColor, secondColor.cgColor]
        swipeGradientLayer?.locations = [0.0, 1.0]
        swipeGradientLayer?.startPoint = CGPoint(x: 1.0, y: 0.0)
        swipeGradientLayer?.endPoint = CGPoint(x: 0.0, y: 0.0)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        return abs((pan.velocity(in: pan.view)).x) > abs((pan.velocity(in: pan.view)).y)
    }
    
    @IBAction func logInButtonTapped(_ sender: Any) {
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
                
                guard let maxValue = maxValue else { return }
                guard let minValue = minValue else { return }
                let limitToUpper = min(translationX, maxValue)
                constant = max(limitToUpper, minValue)
            } else if swipeMode == .delete {
                maxValue = -(view.frame.size.width * 0.5)
                minValue = 0
                
                guard let maxValue = maxValue else { return }
                guard let minValue = minValue else { return }
                let limitToUpper = max(translationX, maxValue)
                constant = min(limitToUpper, minValue)
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
    
    func set(to state: SwipeState, as type: SwipeMode? = nil, animated: Bool = true) {
        swipeState = state
        let width = rectangleView.frame.size.width
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
        
        let block = { [weak self] in
            self?.cardContainerCenterXConstraint.constant = constant
            self?.layoutIfNeeded()
        }
        
        guard animated else {
            block()
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            block()
        }
    }
}
