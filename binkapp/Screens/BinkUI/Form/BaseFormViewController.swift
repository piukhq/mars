//
//  BaseFormViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 14/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class BaseFormViewController: UIViewController {
    
    // MARK: - Helpers
    
    private struct Constants {
        static let cellHeight: CGFloat = 80.0
        static let horizontalInset: CGFloat = 25.0
        static let maskingInset: CGFloat = 209.0
        static let buttonWidthPercentage: CGFloat = 0.75
        static let buttonHeight: CGFloat = 52.0
    }
    
    // MARK: - Properties
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(FormCollectionViewCell.self)
        collectionView.alwaysBounceVertical = true
        let height = CGFloat(dataSource.fields.count) * Constants.cellHeight
        collectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
        return collectionView
    }()
    
    lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [titleLabel, descriptionLabel, collectionView], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.margin = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        view.addSubview(stackView)
        return stackView
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.headline
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
        maskingView.backgroundColor = .white
        view.addSubview(maskingView)
        return maskingView
    }()
    
    private lazy var addButton: BinkGradientButton = {
        let button = BinkGradientButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add", for: .normal)
        button.titleLabel?.font = UIFont.buttonText
        view.addSubview(button)
        return button
    }()
    
    lazy var layout = UICollectionViewFlowLayout()
    
    let dataSource: FormDataSource
    
    // MARK: - Initialisation
    
    init(title: String, description: String, dataSource: FormDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
        configureLayout()
        titleLabel.text = title
        descriptionLabel.text = description
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if collectionView.contentSize.equalTo(.zero) { collectionView.layoutIfNeeded() }
        setBottomItemMask()
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            maskingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            maskingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            maskingView.heightAnchor.constraint(equalToConstant: Constants.maskingInset),
            maskingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.buttonWidthPercentage),
            addButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            addButton.centerYAnchor.constraint(equalTo: maskingView.centerYAnchor),
            addButton.centerXAnchor.constraint(equalTo: maskingView.centerXAnchor),
            ])
    }
    
    private func setBottomItemMask() {
        let maskGradient = CAGradientLayer()
        maskGradient.frame = maskingView.bounds
        maskGradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        maskGradient.locations = [0.0, 0.9]
        
        maskingView.layer.mask = maskGradient
    }
}

extension BaseFormViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: Constants.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
