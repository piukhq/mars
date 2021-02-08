//
//  PaymentScannerWidgetView.swift
//  Pods
//
//  Created by Sean Williams on 30/10/2020.
//

import UIKit

class PaymentScannerWidgetView: UIView {
    struct Constants {
        static let cornerRadius: CGFloat = 4
        static let fontSize: CGFloat = 18.0
    }

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var explainerLabel: UILabel!

    private var timer: Timer?
    private var view: UIView!
    private var reuseableId: String {
        return String(describing: type(of: self))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        configure()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.reuseableId, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }

    func addTarget(_ target: Any?, selector: Selector?) {
        addGestureRecognizer(UITapGestureRecognizer(target: target, action: selector))
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func configure(withThemeDelegate themeDelegate: ThemeDelegate? = nil) {
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius
        backgroundColor = themeDelegate?.backgroundColor
        titleLabel.font = UIFont(name: "NunitoSans-ExtraBold", size: Constants.fontSize)
        titleLabel.textColor = themeDelegate?.textColor
        explainerLabel.font = UIFont(name: "NunitoSans-Light", size: Constants.fontSize)
        explainerLabel.numberOfLines = 2
        explainerLabel.adjustsFontSizeToFitWidth = true
        explainerLabel.minimumScaleFactor = 0.4
        explainerLabel.textColor = themeDelegate?.textColor
        imageView.image = UIImage(named: "loyalty_scanner_enter_manually")
        
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { [weak self] _ in
                let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
                notificationFeedbackGenerator.prepare()
                notificationFeedbackGenerator.notificationOccurred(.error)
                
                let animation = CAKeyframeAnimation(keyPath: "transform.scale")
                animation.timingFunction = CAMediaTimingFunction(name: .linear)
                animation.duration = 0.6
                animation.speed = 0.8
                animation.values = [0.9, 1.1, 0.9, 1.1, 0.95, 1.05, 0.98, 1.02, 1.0]
                self?.layer.add(animation, forKey: "shake")
                self?.imageView.image = UIImage(named: "loyalty_scanner_error")
            })
        }
    }
}

