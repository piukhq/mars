//
//  ResponseCodeVisualiser.swift
//  binkapp
//
//  Created by Sean Williams on 20/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class DebugInfoAlertView: UIView {
    enum AlertType {
        case success
        case warning
        case failure
        case info
    }
    
    private let message: String
    private var type: AlertType
    private var timer: Timer?
    
    private lazy var textLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: self.bounds.origin.x + 10, y: self.bounds.origin.y, width: self.bounds.width - 20, height: self.bounds.height))
        label.textAlignment = .center
        label.textColor = .white
        label.font = .alertText
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    init(message: String, type: AlertType, window: UIWindow) {
        self.message = message
        self.type = type
        super.init(frame: CGRect(x: 25, y: 0, width: window.bounds.width - 50, height: 50))
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func show(_ message: String, type: DebugInfoAlertView.AlertType) {
        guard Configuration.isDebug else { return }
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            if let statusCodeView = window.subviews.first(where: { $0.isKind(of: DebugInfoAlertView.self) }) as? DebugInfoAlertView {
                statusCodeView.type = type
                statusCodeView.update(message: message)
            } else {
                let view = DebugInfoAlertView(message: message, type: type, window: window)
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
            self.frame = CGRect(x: self.frame.origin.x, y: 50, width: self.frame.width, height: self.frame.height)
        }
    }
    
    private func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: self.frame.origin.x, y: -50, width: self.frame.width, height: self.frame.height)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    func update(message: String) {
        timer?.invalidate()
        UIView.transition(with: textLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.textLabel.text = message
            
            switch self.type {
            case .success:
                self.backgroundColor = .systemGreen
            case .warning:
                self.backgroundColor = .amberPending
            case .failure:
                self.backgroundColor = .systemRed
            default:
                self.backgroundColor = .grey10
            }
        })
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            self.hide()
        }
    }
    
    private func configure() {
        addSubview(textLabel)
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
    }
}
