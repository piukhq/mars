//
//  HyperlinkAlertController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class HyperlinkAlertController: UIViewController {
    @IBOutlet weak var customTitleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    private let titleString: String
    private let messageAttributedString: NSAttributedString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    init(title: String, message: NSAttributedString) {
        self.titleString = title
        self.messageAttributedString = message
        super.init(nibName: "HyperlinkAlertController", bundle: Bundle(for: HyperlinkAlertController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        customTitleLabel.text = titleString
        textView.attributedText = messageAttributedString
    }
    
    // MARK: - Actions
    
    @IBAction func okButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
