//
//  AutofillFormInputAccessory.swift
//  binkapp
//
//  Created by Nick Farrant on 14/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import KeychainAccess
import UIKit

protocol AutofillFormInputAccessoryDelegate: AnyObject {
    func inputAccessory(_ inputAccessory: AutofillFormInputAccessory, didSelectValue value: String)
    func inputAccessoryDidTapDone(_ inputAccessory: AutofillFormInputAccessory)
}

class AutofillFormInputAccessory: UIToolbar {
    lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 1, height: 1)
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return collectionView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleDoneButtonTap), for: .touchUpInside)
        button.setTitle("Done", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stackview: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [collectionView, doneButton])
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.axis = .horizontal
        stackview.spacing = 10
        stackview.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        stackview.isLayoutMarginsRelativeArrangement = true
        addSubview(stackview)
        return stackview
    }()
    
    private let field: FormField
    private weak var autofillDelegate: AutofillFormInputAccessoryDelegate?
    
    init(field: FormField, delegate: AutofillFormInputAccessoryDelegate) {
        self.field = field
        self.autofillDelegate = delegate
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        sizeToFit()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var autofillValues: [String]? {
        var autofillDictionary: [String: [String]] = AutofillUtil.storedDataFromKeychain() ?? [:]
        
        if let userEmail = Current.userManager.currentEmailAddress {
            /// If the email key already exists, append user email if unique
            if field.title.lowercased() == AutofillUtil.email, var storedEmailAddresses = autofillDictionary[AutofillUtil.email] {
                if !storedEmailAddresses.contains(userEmail) {
                    storedEmailAddresses.append(userEmail)
                    autofillDictionary[AutofillUtil.email] = storedEmailAddresses
                }
            } else {
                /// If the key doesn't exist, add it
                autofillDictionary[AutofillUtil.email] = [userEmail]
            }
        }

        return autofillDictionary[field.title.lowercased()]?.sorted()
    }
    
    private func configure() {
        collectionView.register(AutofillFormInputCell.self, asNib: false)
        stackview.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        stackview.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    @objc func handleDoneButtonTap() {
        autofillDelegate?.inputAccessoryDidTapDone(self)
    }
}


// MARK: - CollectionView delegates

extension AutofillFormInputAccessory: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return autofillValues?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AutofillFormInputCell = collectionView.dequeue(indexPath: indexPath)
        guard let value = autofillValues?[indexPath.row] else { return cell }
        cell.configureWithValue(value)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let value = autofillValues?[indexPath.row] {
            autofillDelegate?.inputAccessory(self, didSelectValue: value)
        }
    }
}
