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
    
    struct MessageButton {
        enum ButtonType {
            case success
            case error
        }
        
        let title: String
        let type: ButtonType
        let action: EmptyCompletionBlock
        
        var textColor: UIColor {
            switch type {
            case .success:
                return .greenOk
            case .error:
                return .binkDynamicRed
            }
        }
    }
    
    private let message: String
    private var type: MessageType
    private let messageButton: MessageButton?
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
    
    
    init(message: String, type: MessageType, window: UIWindow, button: MessageButton? = nil) {
        self.message = message
        self.type = type
        self.messageButton = button

        var originFrame: CGRect
        switch type {
        case .snackbar:
            originFrame = CGRect(x: 25, y: window.bounds.height, width: window.bounds.width - 50, height: 70)
        case .responseCodeVisualizer:
            originFrame = CGRect(x: 25, y: 0, width: window.bounds.width - 50, height: 70)
        }
        super.init(frame: originFrame)
        
        if let button = button {
            self.button.setTitle(button.title.capitalized, for: .normal)
            self.button.setTitleColor(button.textColor, for: .normal)
            stackview.addArrangedSubview(self.button)
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
        
        configureGestureRecognizer(direction: .up)
        configureGestureRecognizer(direction: .down)
        configureGestureRecognizer(direction: .left)
        configureGestureRecognizer(direction: .right)
    }
    
    @objc func performAction () {
        messageButton?.action()
    }
    
    static func show(_ message: String, type: MessageType, button: MessageButton? = nil) {
        guard Configuration.isDebug() else { return }
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            if let infoAlertView = window.subviews.first(where: { $0.isKind(of: MessageView.self) }) as? MessageView {
                infoAlertView.hideSideways(direction: .left) {
                    configureMessageView(message, type: type, window: window, button: button)
                }
            } else {
                configureMessageView(message, type: type, window: window, button: button)
            }
        } else {
            fatalError("Couldn't get window")
        }
    }
    
    static private func configureMessageView(_ message: String, type: MessageType, window: UIWindow, button: MessageButton? = nil) {
        let view = MessageView(message: message, type: type, window: window, button: button)
        window.addSubview(view)
        DispatchQueue.main.async {
            view.show()
        }
    }
    
    private func show() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: type.timeInterval, repeats: false) { _ in
            self.hide()
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
    
    private func hideSideways(direction: UISwipeGestureRecognizer.Direction, completion: (() -> Void)? = nil) {
        let xOffset: CGFloat = direction == .left ? -500 : 500
        UIView.animate(withDuration: 0.2, animations: {
            self.frame = CGRect(x: xOffset, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
    
    private func configureGestureRecognizer(direction: UISwipeGestureRecognizer.Direction) {
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: .handleSwipe)
        gestureRecognizer.delegate = self
        gestureRecognizer.direction = direction
        self.addGestureRecognizer(gestureRecognizer)
    }

    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
        timer?.invalidate()

        switch gesture.direction {
        case .down, .up:
            hide()
        case .left, .right:
            hideSideways(direction: gesture.direction)
        default:
            break
        }
    }
}

private extension Selector {
    static let handleSwipe = #selector(MessageView.handleSwipe(gesture:))
}
