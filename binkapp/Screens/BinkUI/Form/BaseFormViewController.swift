//
//  BaseFormViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 14/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import SwiftUI

protocol FormDelegate {
    func formValidityUpdated(fullFormIsValid: Bool)
}

class BaseFormViewController: BinkViewController, FormDelegate, ObservableObject {
    // MARK: - Helpers
    
    private enum Constants {
        static let normalCellHeight: CGFloat = 84.0
        static let horizontalInset: CGFloat = 25.0
        static let bottomInset: CGFloat = 150.0
        static let postCollectionViewPadding: CGFloat = 15.0
        static let offsetPadding: CGFloat = 30.0
    }
    
    // MARK: - Properties
    
    lazy var collectionView: NestedCollectionView = {
        let collectionView = NestedCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = dataSource
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(FormCollectionViewCell.self)
        return collectionView
    }()
    
    private lazy var formView = makeFormView()
    
    lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [titleLabel, descriptionLabel, textView], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.margin = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.bottomInset, right: 0)
        stackView.customPadding(Constants.postCollectionViewPadding, after: textView)
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
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -5)
        textView.linkTextAttributes = [.foregroundColor: UIColor.blueAccent, .underlineStyle: NSUnderlineStyle.single.rawValue]
        return textView
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1) // To invoke automatic self sizing
        return flowLayout
    }()
    
    var initialContentOffset: CGPoint = .zero
    var selectedCellYOrigin: CGFloat = 0.0
    var selectedCellHeight: CGFloat = 0.0
    
    @Published var dataSource: FormDataSource {
        didSet {
//            collectionView.dataSource = dataSource
//            collectionView.reloadData()
//            configureFormView(with: dataSource, update: true)
            formView.rootView = BinkFormView(datasource: dataSource)
            configureCheckboxes()
        }
    }
    
    // MARK: - Initialisation
    
    init(title: String, description: String, attributedDescription: NSMutableAttributedString? = nil, dataSource: FormDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = title
        descriptionLabel.text = description
        if let attrDescription = attributedDescription {
            textView.attributedText = attrDescription
            textView.delegate = self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if collectionView.contentSize.height == 0 { collectionView.layoutIfNeeded() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
//        configureFormView(with: dataSource)
        
        stackScrollView.add(arrangedSubview: formView.view)

        configureCheckboxes()

        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        titleLabel.textColor = Current.themeManager.color(for: .text)
        descriptionLabel.textColor = Current.themeManager.color(for: .text)
        textView.textColor = Current.themeManager.color(for: .text)
        Current.themeManager.overrideUserInterfaceStyle(for: collectionView)
    }
    
//    private func configureFormView(with datasource: FormDataSource, update: Bool = false) {
//        let formController = UIHostingController(rootView: BinkFormView().environmentObject(dataSource))
//        if let form = formController.view {
//            addChild(formController)
//            form.translatesAutoresizingMaskIntoConstraints = false
//
//            if update {
//                for (i, subview) in stackScrollView.arrangedSubviews.enumerated().reversed() {
//                    if subview.isKind(of: CheckboxView.self) {
//                        stackScrollView.remove(arrangedSubview: subview)
//                    }
//
//                    if (i + 1) > 3 {
//                        stackScrollView.remove(arrangedSubview: subview)
//                    }
//                }
//            }
//
//            stackScrollView.add(arrangedSubview: form)
//            stackScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.bottomInset, right: 0)
//        }
//    }
    
    func makeFormView() -> UIHostingController<BinkFormView> {
        let formView = BinkFormView(datasource: dataSource)
        let formController = UIHostingController(rootView: formView)
        addChild(formController)
        formController.didMove(toParent: self)
        formController.view.translatesAutoresizingMaskIntoConstraints = false
        
        stackScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.bottomInset, right: 0)
        return UIHostingController(rootView: formView)
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func configureCheckboxes() {
        for subview in stackScrollView.arrangedSubviews {
            if subview.isKind(of: CheckboxView.self) {
                subview.removeFromSuperview()
            }
        }
        guard !dataSource.checkboxes.isEmpty else { return }
        stackScrollView.add(arrangedSubviews: dataSource.checkboxes)
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }

            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                let visibleOffset = UIScreen.main.bounds.height - keyboardHeight
                let cellVisibleOffset = self.selectedCellYOrigin + self.selectedCellHeight

                if cellVisibleOffset > visibleOffset {
                    let actualOffset = self.stackScrollView.contentOffset.y
                    let neededOffset = CGPoint(x: 0, y: Constants.offsetPadding + actualOffset + cellVisibleOffset - visibleOffset)
                    self.stackScrollView.setContentOffset(neededOffset, animated: true)

                    /// From iOS 14, we are seeing this method being called more often than we would like due to a notification trigger not only when the cell's text field is selected, but when typed into.
                    /// We are resetting these values so that the existing behaviour will still work, whereby these values are updated from delegate methods when they should be, but when the notification is
                    /// called from text input, these won't be updated and therefore will remain as 0.0, and won't fall into this if statement and won't update the content offset of the stack scroll view.
                    self.selectedCellYOrigin = 0.0
                    self.selectedCellHeight = 0.0
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

extension BaseFormViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
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
