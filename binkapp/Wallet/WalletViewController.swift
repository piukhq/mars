//
//  WalletViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 15/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class WalletViewController<T: WalletViewModel>: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BarBlurring {
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.contentInset = LayoutHelper.WalletDimensions.contentInset

        return collectionView
    }()

    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = LayoutHelper.WalletDimensions.cardLineSpacing
        return layout
    }()

    internal lazy var blurBackground = defaultBlurredBackground()

    let refreshControl = UIRefreshControl()

    let viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .didLoadWallet, object: nil)

        refreshControl.addTarget(self, action: #selector(reloadWallet), for: .valueChanged)

        configureCollectionView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        refreshControl.endRefreshing()
        super.viewWillDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let bar = navigationController?.navigationBar else { return }
        prepareBarWithBlur(bar: bar, blurBackground: blurBackground)
    }

    func configureCollectionView() {
        collectionView.register(WalletJoinCardCollectionViewCell.self, asNib: true)
        view.addSubview(collectionView)
        collectionView.addSubview(refreshControl)

        collectionView.dataSource = self
        collectionView.delegate = self

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    @objc func reloadWallet() {
        viewModel.reloadWallet()
    }

    @objc private func refresh() {
        refreshControl.endRefreshing()
        collectionView.reloadData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cardCount + viewModel.joinCardCount
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row < viewModel.joinCardCount {
            return LayoutHelper.WalletDimensions.joinCardSize
        } else {
            return LayoutHelper.WalletDimensions.cardSize
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Should be implemented by subclass")
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < viewModel.joinCardCount {
            // join card
        } else {
            guard let card = viewModel.card(forIndexPath: indexPath) else {
                return
            }

            viewModel.toCardDetail(for: card)
        }
    }
}
