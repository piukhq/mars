//
//  ResponseCodeVisualiser.swift
//  binkapp
//
//  Created by Sean Williams on 20/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

final class ResponseCodeVisualiser {
    static func show(_ statusCode: Int) {
        guard Current.userDefaults.bool(forDefaultsKey: .responseCodeVisualiser) else { return }
        guard let window = UIApplication.shared.keyWindow else {
            fatalError("Couldn't get window.")
        }
        
        if let statusCodeView = window.subviews.first(where: { $0.isKind(of: StatusCodeAlertView.self) }) as? StatusCodeAlertView {
            statusCodeView.update(withStatusCode: statusCode)
        } else {
            let view = StatusCodeAlertView(statusCode: statusCode, window: window)
            window.addSubview(view)
            DispatchQueue.main.async {
                view.show()
            }
        }
    }
}

class StatusCodeAlertView: UIView {
    private let successStatusRange = 200...299
    private let statusCode: Int
    private var timer: Timer?
    
    private lazy var textLabel: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    init(statusCode: Int, window: UIWindow) {
        self.statusCode = statusCode
        super.init(frame: CGRect(x: (window.bounds.width / 2) - 25, y: -50, width: 50, height: 30))
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        update(withStatusCode: statusCode)
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
    
    func update(withStatusCode statusCode: Int) {
        timer?.invalidate()
        UIView.transition(with: textLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.textLabel.text = String(statusCode)
        })
        
        backgroundColor = successStatusRange.contains(statusCode) ? .systemGreen : .systemRed
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            self.hide()
        }
    }
    
    private func configure() {
        addSubview(textLabel)
        layer.cornerRadius = 15
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
    }
}
