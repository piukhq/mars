//
//  InfoAlertView.swift
//  binkapp
//
//  Created by Sean Williams on 20/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

enum ResponseCodeVisualizer {
    case success
    case warning
    case failure
    case info
}

class InfoAlertView: UIView {
    enum AlertType: Equatable {
        enum Length {
            case short
            case long
        }
        
        case snackbar(Length)
        case responseCodeVisualizer(ResponseCodeVisualizer)

        var showOffset: CGFloat {
            switch self {
            case .snackbar:
                return UIScreen.main.bounds.height - 100
            case .responseCodeVisualizer:
                return 50
            }
        }
        
        var hideOffset: CGFloat {
            switch self {
            case .snackbar:
                return UIScreen.main.bounds.height + 100
            case .responseCodeVisualizer:
                return -50
            }
        }
        
        var timeInterval: Double {
            switch self {
            case .snackbar(let snackbarType):
                switch snackbarType {
                case .short:
                    return 1.5
                case .long:
                    return 2.75
                }
            case .responseCodeVisualizer:
                return 2.9
            }
        }
    }
    
    private let message: String
    private var type: AlertType
    private var timer: Timer?
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = .alertText
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Action", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .buttonText
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    private lazy var stackview: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [textLabel, button])
        stackview.frame = CGRect(x: self.bounds.origin.x + 20, y: self.bounds.origin.y, width: self.bounds.width - 40, height: self.bounds.height)
        stackview.axis = .horizontal
        stackview.distribution = .fill
        stackview.spacing = 15
        return stackview
    }()
    
    init(message: String, type: AlertType, window: UIWindow) {
        self.message = message
        self.type = type
        
        var originFrame: CGRect
        switch type {
        case .snackbar:
            originFrame = CGRect(x: 25, y: window.bounds.height, width: window.bounds.width - 50, height: 70)
        case .responseCodeVisualizer:
            originFrame = CGRect(x: 25, y: 0, width: window.bounds.width - 50, height: 70)
        }
        super.init(frame: originFrame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        addSubview(stackview)
    }
    
    static func show(_ message: String, type: AlertType) {
        guard Configuration.isDebug() else { return }
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            if let statusCodeView = window.subviews.first(where: { $0.isKind(of: InfoAlertView.self) }) as? InfoAlertView {
                statusCodeView.type = type
                statusCodeView.update(message: message)
            } else {
                let view = InfoAlertView(message: message, type: type, window: window)
                window.addSubview(view)
                DispatchQueue.main.async {
                    view.show()
                }
            }
        } else {
            fatalError("Couldn't get window")
        }
    }
    
    func show() {
        update(message: message)
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: self.frame.origin.x, y: self.type.showOffset, width: self.frame.width, height: self.frame.height)
        }
    }
    
    private func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: self.frame.origin.x, y: self.type.hideOffset, width: self.frame.width, height: self.frame.height)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    func update(message: String) {
        timer?.invalidate()
        UIView.transition(with: textLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.textLabel.text = message
            
            switch self.type {
            case .responseCodeVisualizer(let infoType):
                switch infoType {
                case .success:
                    self.backgroundColor = .systemGreen
                case .warning:
                    self.backgroundColor = .amberPending
                case .failure:
                    self.backgroundColor = .systemRed
                default:
                    self.backgroundColor = .grey10
                }
            case .snackbar(let snackbarType):
                switch snackbarType {
//                case .short:
//                    self.backgroundColor = .systemGray
//                case .long:
//                    self.backgroundColor = .systemPink
                default:
                    self.backgroundColor = .black.lighter(by: 20)
                }
            }
        })
        
        timer = Timer.scheduledTimer(withTimeInterval: type.timeInterval, repeats: false) { _ in
//            self.hide()
        }
    }
}
