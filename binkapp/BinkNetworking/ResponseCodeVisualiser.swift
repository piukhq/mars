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
    private let type: AlertType
    private var timer: Timer?
    
    private lazy var textLabel: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    init(message: String, type: AlertType, window: UIWindow) {
        self.message = message
        self.type = type
        super.init(frame: CGRect(x: (window.bounds.width / 2) - 25, y: -50, width: 50, height: 30))
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func show(_ message: String, type: DebugInfoAlertView.AlertType) {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            if let statusCodeView = window.subviews.first(where: { $0.isKind(of: DebugInfoAlertView.self) }) as? DebugInfoAlertView {
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
        })
        
        switch type {
        case .success:
            backgroundColor = .systemGreen
        case .warning:
            backgroundColor = .amberPending
        case .failure:
            backgroundColor = .systemRed
        default:
            backgroundColor = .grey10
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            self.hide()
        }
    }
    
    private func configure() {
        addSubview(textLabel)
        layer.cornerRadius = 15
        layer.cornerCurve = .continuous
    }
}
