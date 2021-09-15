//
//  PaymentCardCollectionViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 24/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

import SwiftUI

struct PaymentCardCellSwiftUIView: UIViewRepresentable {
    var paymentCard: PaymentCardCreateModel?
//    func makeCoordinator() -> Coordinator {
//        Coordinator(checkedState: $checkedState, url: $didTapOnURL)
//    }
    
    func makeUIView(context: Context) -> PaymentCardCollectionViewCell {
        let cell: PaymentCardCollectionViewCell = .fromNib()
        guard let paymentCard = paymentCard else { return cell }
        cell.configureWithAddViewModel(paymentCard)
        return cell
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

// TECH DEBT: This is duplicated from loyalty cards.
protocol WalletPaymentCardCollectionViewCellDelegate: AnyObject {
    func cellSwipeBegan(cell: PaymentCardCollectionViewCell)
    func cellDidFullySwipe(action: SwipeMode?, cell: PaymentCardCollectionViewCell)
    func cellPerform(action: CellAction, cell: PaymentCardCollectionViewCell)
}

class PaymentCardCollectionViewCell: WalletCardCollectionViewCell, UIGestureRecognizerDelegate {
    @IBOutlet private weak var nameOnCardLabel: UILabel!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var statusImageView: UIImageView!
    @IBOutlet private weak var providerLogoImageView: UIImageView!
    @IBOutlet private weak var providerWatermarkImageView: UIImageView!
    @IBOutlet private weak var alertView: CardAlertView!
    @IBOutlet private weak var cardContainerCenterXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var deleteButton: UIButton!
    
    private enum CardGradientKey: NSString {
        case visaGradient
        case mastercardGradient
        case amexGradient
        case unknownGradient
        case swipeGradient
    }
    
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
    
    private var cardGradientLayer: CAGradientLayer?
    private var swipeGradientLayer: CAGradientLayer?
    private var startingOffset: CGFloat = 0
    
    private var viewModel: PaymentCardCellViewModel!
    private weak var delegate: WalletPaymentCardCollectionViewCellDelegate?
    
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupGestureRecognizer() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: .handlePan)
        gestureRecognizer.delegate = self
        containerView.addGestureRecognizer(gestureRecognizer)
    }
    
    private var swipeMode: SwipeMode? {
        didSet {
            guard let mode = swipeMode, mode != oldValue else { return }
            updateColor(with: mode)
            updateButtonState(with: mode)
        }
    }
    private (set) var swipeState: SwipeState?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        set(to: .closed, animated: false)
        deleteButton.isHidden = true
        alertView.isHidden = true
        statusLabel.isHidden = false
        statusImageView.isHidden = false
        
        processGradient(UIColor.deleteSwipeGradientLeft, UIColor.deleteSwipeGradientRight)
        processGradient(type: viewModel.paymentCardType)
    }
    
    func configureWithViewModel(_ viewModel: PaymentCardCellViewModel, enableSwipeGesture: Bool? = true, delegate: WalletPaymentCardCollectionViewCellDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
        
        if enableSwipeGesture ?? true {
            setupGestureRecognizer()
        }
        
        nameOnCardLabel.text = viewModel.nameOnCardText
        cardNumberLabel.attributedText = viewModel.cardNumberText
        
        configureForProvider(cardType: viewModel.paymentCardType)
        configurePaymentCardLinkingStatus()
        
        setLabelStyling()
        setupShadow()
        accessibilityIdentifier = viewModel.nameOnCardText
    }
    
    func configureWithAddViewModel(_ viewModel: PaymentCardCreateModel) {
        nameOnCardLabel.text = viewModel.nameOnCard
        cardNumberLabel.attributedText = cardNumberAttributedString(for: viewModel.fullPan ?? "", type: viewModel.cardType)
        
        configureForProvider(cardType: viewModel.cardType)
        
        setLabelStyling()
        statusLabel.isHidden = true
        setupShadow()
    }
    
    private func cardNumberAttributedString(for incompletePan: String, type: PaymentCardType?) -> NSAttributedString? {
        let unredacted = 4
        var stripped = incompletePan.replacingOccurrences(of: " ", with: "")
        let cardNumberLength = 16 // Hardcoded, fix later
        let cardNumberLengthFromCardType = type?.lengthRange().length ?? cardNumberLength
        let lengthDiff = cardNumberLength - cardNumberLengthFromCardType
        let whitespaceIndexLocations = [4, 11, 18] // Harcoded, fix later
        
        // If the string is too long, cut it from the right
        if stripped.count > cardNumberLength {
            let range = stripped.index(stripped.endIndex, offsetBy: -(cardNumberLength - lengthDiff)) ..< stripped.endIndex
            stripped = String(stripped[range])
        }
        
        let redactTo = cardNumberLength - unredacted
        let offset = max(0, stripped.count - redactTo)
        let length = min(stripped.count, redactTo)
        let endIndex = stripped.index(stripped.endIndex, offsetBy: -offset)
        let range = stripped.startIndex ..< endIndex
        
        // THE AMEX CASE
        if (cardNumberLength - cardNumberLengthFromCardType == 1) && stripped.count >= redactTo {
            stripped.insert("#", at: stripped.startIndex)
        }
        
        var redacted = stripped.replacingCharacters(in: range, with: String(repeating: "•", count: length))
        
        // FORMAT
        let textOffset = (UIFont.buttonText.capHeight - UIFont.redactedCardNumberPrefix.capHeight) / 2
        var padRange = 0
        whitespaceIndexLocations.forEach { spaceIndex in
            if redacted.count > spaceIndex {
                let space = "   "
                redacted.insert(contentsOf: space, at: redacted.index(redacted.startIndex, offsetBy: spaceIndex))
                padRange += space.count
            }
        }
        
        /*
        The below is kind of a nightmare. Due to the way UILabel draws itself, we need the lineheight to be set to a constant
        so that when an unredacted character (of a different font size) is added, there is no visual vertical shifting taking
        place. Due to using NSAttributedString we've lost some safety because we have to use NSRange.
        */
        
        let attributedString = NSMutableAttributedString(string: redacted)
        var nsRange = NSRange(range, in: stripped)
        nsRange.length += padRange
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 25 // Discovered via trial and error, come back and fix some other time
        attributedString.addAttributes([.font: UIFont.redactedCardNumberPrefix, .kern: 1.5, .paragraphStyle: style, .baselineOffset: textOffset], range: nsRange)
        attributedString.addAttributes([.font: UIFont.buttonText, .kern: 0.2], range: NSRange(location: nsRange.length, length: redacted.count - (nsRange.length)))
        
        return attributedString
    }
    
    private func setLabelStyling() {
        nameOnCardLabel.font = .subtitle
        statusLabel.font = .statusLabel
        
        [nameOnCardLabel, cardNumberLabel, statusLabel].forEach {
            $0?.textColor = .white
        }
    }
    
    private func configureForProvider(cardType: PaymentCardType?) {
        guard let type = cardType else {
            processGradient(type: cardType)
            providerLogoImageView.image = nil
            providerWatermarkImageView.image = nil
            return
        }
        providerLogoImageView.image = UIImage(named: type.logoName)
        providerWatermarkImageView.image = UIImage(named: type.sublogoName)
        processGradient(type: type)
    }
    
    private func configurePaymentCardLinkingStatus() {
        guard !viewModel.paymentCardIsExpired else {
            alertView.configureForType(.paymentExpired) { [weak self] in
                self?.viewModel.expiredAction()
            }
            alertView.isHidden = false
            statusLabel.isHidden = true
            statusImageView.isHidden = true
            return
        }
        
        statusLabel.text = viewModel.statusText
        statusImageView.isHidden = !viewModel.paymentCardIsActive
        statusImageView.image = imageForLinkedStatus()
    }
    
    private func imageForLinkedStatus() -> UIImage? {
        return viewModel.paymentCardIsLinkedToMembershipCards ? Asset.linked.image : Asset.unlinked.image
    }
    
    private func processGradient(type: PaymentCardType?) {
        cardGradientLayer?.removeFromSuperlayer()
        let gradient = CAGradientLayer()
        containerView.layer.insertSublayer(gradient, at: 0)
        cardGradientLayer = gradient
        cardGradientLayer?.frame = bounds
        cardGradientLayer?.locations = [0.0, 1.0]
        cardGradientLayer?.startPoint = CGPoint(x: 1.0, y: 0.0)
        cardGradientLayer?.endPoint = CGPoint(x: 0.0, y: 0.0)
        cardGradientLayer?.cornerRadius = LayoutHelper.WalletDimensions.cardCornerRadius
        switch type {
        case .visa:
            cardGradientLayer?.colors = UIColor.visaPaymentCardGradients
        case .mastercard:
            cardGradientLayer?.colors = UIColor.mastercardPaymentCardGradients
        case .amex:
            cardGradientLayer?.colors = UIColor.amexPaymentCardGradients
        case .none:
            cardGradientLayer?.colors = UIColor.unknownPaymentCardGradients
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.priority = .almostRequired
        width.constant = bounds.size.width
        height.constant = bounds.size.height
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: targetSize.height))
    }
}

private extension Selector {
    static let handlePan = #selector(PaymentCardCollectionViewCell.handlePan(gestureRecognizer:))
}

// MARK: - Swiping

// TECH DEBT: This is all tech debt, as it duplicates in majority the code from loyalty card cells
// Should be made reusable across all WalletCard types

extension PaymentCardCollectionViewCell {
    private func updateColor(with swipeMode: SwipeMode) {
        switch swipeMode {
        case .delete:
            processGradient(.deleteSwipeGradientLeft, .deleteSwipeGradientRight)
        case .barcode:
            return
        case .unset:
            return
        }
    }
    
    private func updateButtonState(with swipeMode: SwipeMode) {
        switch swipeMode {
        case .delete:
            deleteButton.isHidden = false
        case .barcode:
            deleteButton.isHidden = true
        case .unset:
            deleteButton.isHidden = false
        }
    }
    
    private func processGradient(_ firstColor: UIColor, _ secondColor: UIColor) {
        swipeGradientLayer?.removeFromSuperlayer()
        let swipeGradient = CAGradientLayer()
        contentView.layer.insertSublayer(swipeGradient, at: 0)
        swipeGradientLayer = swipeGradient
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
            
            if swipeMode == .barcode && translationX > 0 {
                // Barcode is disabled on payment card but the cell can be swiped back when the cell is in peek mode
                constant = 0
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
        let width = containerView.frame.size.width
        let constant: CGFloat
        
        switch state {
        case .closed:
            constant = 0
        case .peek:
            guard let type = type else { return }
            
            if type == .barcode {
                constant = 0 // Barcode is disabled on payment card swipes
            } else {
                constant = -(width * 0.3)
            }
        case .expanded:
            guard let type = type else { return }
            
            if type == .barcode {
                constant = 0 // Barcode is disabled on payment card swipes
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
