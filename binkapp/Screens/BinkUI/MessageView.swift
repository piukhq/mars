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

class MessageView: UIView, UIGestureRecognizerDelegate {
    enum MessageType: Equatable {
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
    private var type: MessageType
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
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .buttonText
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(performAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackview: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [textLabel])
        stackview.frame = CGRect(x: self.bounds.origin.x + 20, y: self.bounds.origin.y, width: self.bounds.width - 40, height: self.bounds.height)
        stackview.axis = .horizontal
        stackview.distribution = .fill
        stackview.spacing = 15
        return stackview
    }()
    
    private let action: BinkButtonAction?
    
    init(message: String, type: MessageType, actionTitle: String?, window: UIWindow, action: BinkButtonAction?) {
        self.message = message
        self.type = type
        self.action = action

        var originFrame: CGRect
        switch type {
        case .snackbar:
            originFrame = CGRect(x: 25, y: window.bounds.height, width: window.bounds.width - 50, height: 70)
        case .responseCodeVisualizer:
            originFrame = CGRect(x: 25, y: 0, width: window.bounds.width - 50, height: 70)
        }
        super.init(frame: originFrame)
        
        if let actionTitle = actionTitle {
            button.setTitle(actionTitle, for: .normal)
            stackview.addArrangedSubview(button)
        }
        self.textLabel.text = message
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        layer.cornerRadius = 15
        layer.cornerCurve = .continuous
        addSubview(stackview)
        
        switch type {
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
        case .snackbar:
            self.backgroundColor = .black.lighter(by: 20)
        }
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: .handlePan)
        gestureRecognizer.delegate = self
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func performAction () {
        action?()
    }
    
    static func show(_ message: String, type: MessageType, actionTitle: String? = nil, buttonAction: BinkButtonAction? = nil) {
        guard Configuration.isDebug() else { return }
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            if let infoAlertView = window.subviews.first(where: { $0.isKind(of: MessageView.self) }) as? MessageView {
                infoAlertView.hideLeft() {
                    configureMessageView(message, type: type, window: window, actionTitle: actionTitle, buttonAction: buttonAction)
                }
            } else {
                configureMessageView(message, type: type, window: window, actionTitle: actionTitle, buttonAction: buttonAction)
            }
        } else {
            fatalError("Couldn't get window")
        }
    }
    
    static private func configureMessageView(_ message: String, type: MessageType, window: UIWindow, actionTitle: String? = nil, buttonAction: BinkButtonAction? = nil) {
        let view = MessageView(message: message, type: type, actionTitle: actionTitle, window: window, action: buttonAction)
        window.addSubview(view)
        DispatchQueue.main.async {
            view.show()
        }
    }
    
    private func show() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: type.timeInterval, repeats: false) { _ in
//            self.hide()
        }
        
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
    
    private func hideLeft(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: {
            self.frame = CGRect(x: -500, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        }) { _ in
            self.removeFromSuperview()
            completion()
        }
    }

    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        let translationX = gesture.translation(in: view.superview).x * 1.3
        print(translationX)
        
        // TODO: - Use Pan gesture instead
        
//        timer?.invalidate()
//        var frame = self.frame
//
//        frame.origin.y += 100
//
//        UIView.animate(withDuration: 0.3) {
//            self.frame = frame
//        }
        
//        switch gesture.direction {
//        case .down:
//            print(gesture)
//        default:
//            break
//        }
    }
}

private extension Selector {
    static let handlePan = #selector(MessageView.handlePan(gesture:))
}
