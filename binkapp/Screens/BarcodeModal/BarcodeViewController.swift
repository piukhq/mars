//
//  BarcodeViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import SwiftUI

class BarcodeViewController: BinkViewController {
    enum Constants {
        static let largeSpace: CGFloat = 20
        static let smallSpace: CGFloat = 10
        static let imageCornerRadius: CGFloat = 10
        static let iconImageAspectRatio: CGFloat = 1
        static let horizontalInset: CGFloat = 25.0
        static let bottomInset: CGFloat = 150.0
    }
    
//    @IBOutlet weak var barcodeLabel: UILabel!
//    @IBOutlet weak var barcodeNumberLabel: BinkCopyableLabel!
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var numberLabel: BinkCopyableLabel!
    
    lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [barcodeImageView, logoImageContainerView, descriptionLabel, membershipNumberTitleLabel, membershipNumberHighVisView, barcodeTitleLabel, barcodeNumberHighVisView], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.margin = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: Constants.bottomInset, right: 0)
        stackView.customPadding(Constants.largeSpace, after: barcodeImageView)
        stackView.customPadding(Constants.largeSpace, after: logoImageContainerView)
        stackView.customPadding(Constants.largeSpace, after: descriptionLabel)
        stackView.customPadding(Constants.smallSpace, after: membershipNumberTitleLabel)
        stackView.customPadding(Constants.largeSpace, after: membershipNumberHighVisView)
        stackView.customPadding(Constants.smallSpace, after: barcodeTitleLabel)
        view.addSubview(stackView)
        return stackView
    }()
    
    private lazy var logoImageContainerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 128).isActive = true
        container.addSubview(logoImageView)
        return container
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = Constants.imageCornerRadius
        imageView.layer.cornerCurve = .continuous
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var barcodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private lazy var logoImageViewAspectRatio: NSLayoutConstraint = {
        let aspectRatio = logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor, multiplier: 115 / 182)
        aspectRatio.isActive = true
        return aspectRatio
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.bodyTextLarge
        label.textAlignment = .justified
        return label
    }()
    
    private lazy var membershipNumberTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .headline
        label.text = L10n.cardNumberTitle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var membershipNumberHighVisView: UIView = {
        return configureHighVisibilityView(text: viewModel.cardNumber ?? "")
    }()
    
    private lazy var barcodeNumberHighVisView: UIView = {
        return configureHighVisibilityView(text: viewModel.barcodeNumber)
    }()
    
    private lazy var barcodeTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .headline
        label.text = L10n.barcodeTitle
        return label
    }()
    
    private var previousBrightness: CGFloat?

    let viewModel: BarcodeViewModel
    var hasDrawnBarcode = false
    
    init(viewModel: BarcodeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "BarcodeViewController", bundle: Bundle(for: BarcodeViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = .white
        
        configureLayout()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        previousBrightness = UIScreen.main.brightness
        if viewModel.isBarcodeAvailable {
            UIScreen.main.brightness = 1.0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIScreen.main.brightness = previousBrightness ?? 0.5
    }
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        barcodeTitleLabel.textColor = Current.themeManager.color(for: .text)
        membershipNumberTitleLabel.textColor = Current.themeManager.color(for: .text)
        descriptionLabel.textColor = Current.themeManager.color(for: .text)
    }
    
    private func configureHighVisibilityView(text: String) -> UIView {
        let highVisibilityLabelSwiftUIView = HighVisibilityLabelView(text: text)
        let hostingController = UIHostingController(rootView: highVisibilityLabelSwiftUIView, ignoreSafeArea: true)
        addChild(hostingController)
        hostingController.didMove(toParent: self)
//        hostingController.view.backgroundColor = .clear
        
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showMenu))
//        hostingController.view.addGestureRecognizer(longPressRecognizer)
        return hostingController.view
    }
    
//    @objc private func showMenu(_ sender: Any) {
//        becomeFirstResponder()
//        let menu = UIMenuController.shared
//        if !menu.isMenuVisible {
//            let xPosition = self.intrinsicContentSize.width / 2
//            let rect = CGRect(x: xPosition, y: bounds.midY - 4, width: 0.0, height: 0.0)
//            menu.showMenu(from: self, rect: rect)
//        }
//    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            barcodeImageView.heightAnchor.constraint(equalToConstant: 303),
            logoImageView.topAnchor.constraint(equalTo: logoImageContainerView.topAnchor, constant: 6.5),
            logoImageView.centerXAnchor.constraint(equalTo: logoImageContainerView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoImageContainerView.centerYAnchor),
            logoImageViewAspectRatio
        ])
    }
    
    func configureUI() {
        guard !hasDrawnBarcode else { return }
        
        /// Barcode Image
        barcodeImageView.layoutIfNeeded()
        if let barcodeImage = viewModel.barcodeImage(withSize: barcodeImageView.frame.size) {
            logoImageContainerView.isHidden = true
            barcodeImageView.image = barcodeImage
        } else {
            if let plan = viewModel.membershipCard.membershipPlan {
                barcodeImageView.isHidden = true
                logoImageView.backgroundColor = .purple
                
                ImageService.getImage(forPathType: .membershipPlanAlternativeHero(plan: plan), traitCollection: traitCollection) { [weak self] retrievedImage in
                    if let retrievedImage = retrievedImage {
                        self?.logoImageView.image = retrievedImage
                    } else {
                        ImageService.getImage(forPathType: .membershipPlanIcon(plan: plan), traitCollection: self?.traitCollection) { retrievedImage in
                            /// If we can't retrieve the hero image, adjust aspect ratio and use square icon
                            self?.logoImageView.image = retrievedImage
                            self?.logoImageViewAspectRatio.isActive = false
                            if let heightAnchor = self?.logoImageView.heightAnchor {
                                self?.logoImageView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: Constants.iconImageAspectRatio).isActive = true
                            }
                        }
                    }
                }
            }
        }
        
        /// Description label
        switch viewModel.barcodeUse {
        case .loyaltyCard:
            if viewModel.isBarcodeAvailable {
                descriptionLabel.text = L10n.barcodeCardDescription
            } else {
                descriptionLabel.text = L10n.barcodeCardNumberDescription
            }
        case .coupon:
            descriptionLabel.text = L10n.barcodeCouponDescription
        }
        
        /// Barcode number
        barcodeTitleLabel.isHidden = !viewModel.shouldShowbarcodeNumber
        barcodeNumberHighVisView.isHidden = !viewModel.shouldShowbarcodeNumber

        hasDrawnBarcode = true
    }
}

extension UIHostingController {
    convenience public init(rootView: Content, ignoreSafeArea: Bool) {
        self.init(rootView: rootView)
        
        if ignoreSafeArea {
            disableSafeArea()
        }
    }
    
    func disableSafeArea() {
        guard let viewClass = object_getClass(view) else { return }
        
        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        } else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
            
            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                    return .zero
                }
                class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
            }
            
            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
}
