//
//  BaseFormViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 14/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol Form {
    func formValidityUpdated(fullFormIsValid: Bool)
}

class BaseFormViewController: BinkTrackableViewController, Form {
    // MARK: - Helpers
    
    private enum Constants {
        static let normalCellHeight: CGFloat = 84.0
        static let horizontalInset: CGFloat = 25.0
        static let maskingHeight: CGFloat = 209.0
        static let bottomInset: CGFloat = 150.0
        static let postCollectionViewPadding: CGFloat = 15.0
    }
    
    // MARK: - Properties
    
    lazy var collectionView: NestedCollectionView = {
        let collectionView = NestedCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = dataSource
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(FormCollectionViewCell.self)
        return collectionView
    }()
    
    lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [titleLabel, descriptionLabel, collectionView], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.margin = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.bottomInset, right: 0)
        stackView.customPadding(Constants.postCollectionViewPadding, after: collectionView)
        view.addSubview(stackView)
        return stackView
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.headline
        title.numberOfLines = 0
        return title
    }()
    
    lazy var descriptionLabel: UILabel = {
        let description = UILabel()
        description.translatesAutoresizingMaskIntoConstraints = false
        description.font = UIFont.bodyTextLarge
        description.numberOfLines = 0
        return description
    }()
    
    private lazy var maskingView: UIView = {
        let maskingView = UIView()
        maskingView.translatesAutoresizingMaskIntoConstraints = false
        maskingView.isUserInteractionEnabled = false
        maskingView.backgroundColor = .white
        view.addSubview(maskingView)
        return maskingView
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1) // To invoke automatic self sizing
        return flowLayout
    }()
    
    var initialContentOffset: CGPoint = .zero
    var keyboardHeight: CGFloat = 0.0
    var selectedCellYOrigin: CGFloat = 0.0
    var selectedCellHeight: CGFloat = 0.0
    
    var dataSource: FormDataSource {
        didSet {
            collectionView.dataSource = dataSource
            collectionView.reloadData()
        }
    }
    
    // MARK: - Initialisation
    
    init(title: String, description: String, dataSource: FormDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = title
        descriptionLabel.text = description
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if collectionView.contentSize.height == 0 { collectionView.layoutIfNeeded() }
        setBottomItemMask()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureCheckboxes()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            maskingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            maskingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            maskingView.heightAnchor.constraint(equalToConstant: Constants.maskingHeight),
            maskingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setBottomItemMask() {
        let maskGradient = CAGradientLayer()
        maskGradient.frame = maskingView.bounds
        maskGradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        maskGradient.locations = [0.0, 0.9]
        
        maskingView.layer.mask = maskGradient
    }
    
    private func configureCheckboxes() {
        guard !dataSource.checkboxes.isEmpty else { return }
        stackScrollView.add(arrangedSubviews: dataSource.checkboxes)
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                self.keyboardHeight = keyboardHeight
                
                let visibleOffset = UIScreen.main.bounds.height - keyboardHeight
                let cellVisibleOffset = self.selectedCellYOrigin + self.selectedCellHeight
                
                if cellVisibleOffset > visibleOffset {
                    let actualOffset = self.stackScrollView.contentOffset.y
                    let neededOffset = CGPoint(x: 0, y: actualOffset + cellVisibleOffset - visibleOffset)
                    self.stackScrollView.setContentOffset(neededOffset, animated: true)
                }
            }
        }
    }
    
    /// This method is designed to be overriden for updating UI elements in response to validity
    func formValidityUpdated(fullFormIsValid: Bool) {}
    func checkboxView(_ checkboxView: CheckboxView, didTapOn URL: URL) {}
}

extension BaseFormViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? FormCollectionViewCell else { return }
        
        cell.setWidth(collectionView.frame.size.width)
    }
}

extension BaseFormViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

extension BaseFormViewController {
    func formDataSource(_ dataSource: FormDataSource, fieldDidExit: FormField) {
        collectionView.collectionViewLayout.invalidateLayout()
        formValidityUpdated(fullFormIsValid: dataSource.fullFormIsValid)
        stackScrollView.contentInset.bottom = Constants.bottomInset
    }
}

extension BaseFormViewController: CheckboxViewDelegate {
    func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FormField.ColumnKind) {
        formValidityUpdated(fullFormIsValid: dataSource.fullFormIsValid)
    }
}

class NestedCollectionView: UICollectionView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }
}
