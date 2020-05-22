//
//  WalletViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 15/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class WalletViewController<T: WalletViewModel>: BinkTrackableViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BarBlurring {
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
        layout.estimatedItemSize = LayoutHelper.WalletDimensions.cardSize
        return layout
    }()

    internal lazy var blurBackground = defaultBlurredBackground()

    let refreshControl = UIRefreshControl()
    private var hasSupportUpdates = false

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
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLocal), name: .didLoadLocalWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPostClear), name: .shouldTrashLocalWallets, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopRefreshing), name: .noInternetConnection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopRefreshing), name: .outageError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopRefreshing), name: .outageSilentFail, object: nil)

        refreshControl.addTarget(self, action: #selector(reloadWallet), for: .valueChanged)

        configureCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // We are doing this because the loading indicator is getting stuck when quickly switching between tabs
        // May need to change the approach
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.refreshControl.beginRefreshing()
            self.refreshControl.endRefreshing()
        }
        
        Current.wallet.reloadWalletsIfNecessary()
        configureLoadingIndicator()
        
        checkForZendeskUpdates()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let bar = navigationController?.navigationBar else { return }
        prepareBarWithBlur(bar: bar, blurBackground: blurBackground)
    }
    
    private func configureNavigationItem(hasSupportUpdates: Bool) {
        self.hasSupportUpdates = hasSupportUpdates
        let settingsIcon = UIImage(named: hasSupportUpdates ? "settings-notified" : "settings")?.withRenderingMode(.alwaysOriginal)
        let settingsBarButton = UIBarButtonItem(image: settingsIcon, style: .plain, target: self, action: #selector(settingsButtonTapped))
        tabBarController?.navigationItem.rightBarButtonItem = settingsBarButton
        
        var rightInset: CGFloat = 0
        switch UIDevice.current.width {
            case .iPhone5Size:
                rightInset = 9
            case .iPhone6Size:
                rightInset = 9
            case .iPhonePlusSize:
                rightInset = 6
            default:
                rightInset = 7
        }
        settingsBarButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightInset)
    }
    
    @objc func settingsButtonTapped() {
        viewModel.toSettings(hasSupportUpdates: hasSupportUpdates)
    }
    
    private func checkForZendeskUpdates() {
        ZendeskService.getIdentityRequestUpdates { hasUpdates in
            self.configureNavigationItem(hasSupportUpdates: hasUpdates)
        }
    }

    func configureCollectionView() {
        collectionView.register(WalletPromptCollectionViewCell.self, asNib: true)
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

    func configureLoadingIndicator() {
        if Current.wallet.shouldDisplayLoadingIndicator {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.refreshControl.programaticallyBeginRefreshing(in: self.collectionView)
            }
        }
    }

    @objc func reloadWallet() {
        viewModel.reloadWallet()
    }

    @objc private func refresh() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
        }
        collectionView.reloadData()
    }
    
    @objc private func refreshPostClear() {
        viewModel.refreshLocalWallet()
    }

    @objc private func refreshLocal() {
        collectionView.reloadData()
    }
    
    @objc private func stopRefreshing() {
        if let navigationBar = self.navigationController?.navigationBar {
            refreshControl.programaticallyEndRefreshing(in: self.collectionView, with: navigationBar)
            collectionView.reloadData()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cardCount + viewModel.walletPromptsCount
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row < viewModel.cardCount {
            return LayoutHelper.WalletDimensions.cardSize
        } else {
            return LayoutHelper.WalletDimensions.walletPromptSize
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Should be implemented by subclass")
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < viewModel.cardCount {
            guard let card = viewModel.cards?[indexPath.row] else {
                return
            }
            viewModel.toCardDetail(for: card)
            
        } else {
            guard let joinCard = viewModel.promptCard(forIndexPath: indexPath) else {
                return
            }
            viewModel.didSelectWalletPrompt(joinCard)
        }
    }
}
