//
//  OnboardingViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 21/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class OnboardingViewController: BinkTrackableViewController, UIScrollViewDelegate {
    @IBOutlet private weak var facebookPillButton: BinkPillButton!
    @IBOutlet private weak var floatingButtonsView: BinkPrimarySecondaryButtonView!
    private let viewModel: OnboardingViewModel
    private var didLayoutSubviews = false
    private var timer: Timer?

    private struct Constants {
        static let floatingButtonsHeight: CGFloat = 129.0
    }
    
    lazy var learningContainer: UIView = {
        let container = UIView()
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    lazy var onboardingView1: OnboardingLearningView = {
        let onboardingView = OnboardingLearningView(frame: .zero)
        onboardingView.configure(forType: .pll)
        return onboardingView
    }()

    lazy var onboardingView2: OnboardingLearningView = {
        let onboardingView = OnboardingLearningView(frame: .zero)
        onboardingView.configure(forType: .wallet)
        return onboardingView
    }()

    lazy var onboardingView3: OnboardingLearningView = {
        let onboardingView = OnboardingLearningView(frame: .zero)
        onboardingView.configure(forType: .barcodeOrCollect)
        return onboardingView
    }()

    lazy var onboardingViews: [UIView] = {
        return [
            onboardingView1,
            onboardingView2,
            onboardingView3
        ]
    }()

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        learningContainer.addSubview(scrollView)
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        return scrollView
    }()

    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.numberOfPages = onboardingViews.count
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(changePage(pageControl:)), for: .valueChanged)
        learningContainer.addSubview(pageControl)
        return pageControl
    }()

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startTimer()
        viewModel.navigationController = navigationController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .onboarding)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutSubviews {
            didLayoutSubviews = true
            setLayout()
            configureUI()
        }
    }

    private func setLayout() {
        let learningContainerHeightConstraint = learningContainer.heightAnchor.constraint(equalToConstant: LayoutHelper.Onboarding.learningContainerHeight)
        learningContainerHeightConstraint.priority = .init(999)

        NSLayoutConstraint.activate([
            learningContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutHelper.Onboarding.learningContainerTopPadding),
            learningContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            learningContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            learningContainerHeightConstraint,

            floatingButtonsView.leftAnchor.constraint(equalTo: view.leftAnchor),
            floatingButtonsView.rightAnchor.constraint(equalTo: view.rightAnchor),
            floatingButtonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -LayoutHelper.PrimarySecondaryButtonView.bottomPadding),
            floatingButtonsView.heightAnchor.constraint(equalToConstant: Constants.floatingButtonsHeight),

            facebookPillButton.heightAnchor.constraint(equalToConstant: LayoutHelper.PillButton.height),
            facebookPillButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: LayoutHelper.PillButton.widthPercentage),
            facebookPillButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            facebookPillButton.bottomAnchor.constraint(equalTo: floatingButtonsView.topAnchor, constant: -LayoutHelper.PillButton.verticalSpacing),
            facebookPillButton.topAnchor.constraint(greaterThanOrEqualTo: pageControl.bottomAnchor, constant: 25),

            pageControl.topAnchor.constraint(equalTo: learningContainer.bottomAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: LayoutHelper.Onboarding.pageControlSize.height),
            pageControl.widthAnchor.constraint(equalToConstant: LayoutHelper.Onboarding.pageControlSize.width),
            pageControl.centerXAnchor.constraint(equalTo: learningContainer.centerXAnchor),
        ])
    }

    private func configureUI() {
        facebookPillButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButtonsView.translatesAutoresizingMaskIntoConstraints = false

        facebookPillButton.configureForType(.facebook)
        facebookPillButton.addTarget(self, action: #selector(handleFacebookButtonPressed), for: .touchUpInside)

        floatingButtonsView.configure(primaryButtonTitle: viewModel.signUpWithEmailButtonText, secondaryButtonTitle: viewModel.loginWithEmailButtonText)
        floatingButtonsView.delegate = self

        view.layoutIfNeeded() // Get those autolayout fraaaamez
        scrollView.frame = CGRect(x: 0, y: 0, width: learningContainer.frame.width, height: learningContainer.frame.height)
        scrollView.contentSize = CGSize(width: learningContainer.frame.width * CGFloat(onboardingViews.count), height: learningContainer.frame.height)

        for i in 0..<onboardingViews.count {
            onboardingViews[i].frame = CGRect(x: learningContainer.frame.width * CGFloat(i), y: 0, width: learningContainer.frame.width, height: learningContainer.frame.height)
            scrollView.addSubview(onboardingViews[i])
        }
        
        #if DEBUG
        let tap = UITapGestureRecognizer(target: self, action: #selector(openDebugMenu))
        tap.numberOfTapsRequired = 3
        learningContainer.addGestureRecognizer(tap)
        #endif
    }

    // MARK: Button handlers

    @objc private func handleFacebookButtonPressed() {
        guard Current.apiClient.networkIsReachable else {
            viewModel.router.presentNoConnectivityPopup()
            return
        }
        FacebookLoginController.login(with: self, onSuccess: { [weak self] facebookRequest in
            // If we have no email address, push them onto the add email screen
            guard facebookRequest.email != nil else {
                self?.viewModel.pushToAddEmail(request: facebookRequest)
                return
            }
            
            self?.viewModel.pushToSocialTermsAndConditions(request: facebookRequest)
        }) { [weak self] isCancelled in
            self?.showError(isCancelled)
        }
    }
    
    func showError(_ isCancelled: Bool) {
        let message = isCancelled ? viewModel.facebookLoginCancelledText : viewModel.facebookLoginErrorText
        
        let alert = UIAlertController(title: viewModel.facebookLoginErrorTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: viewModel.facebookLoginOK, style: .default))
        present(alert, animated: true)
    }

    // MARK: - Scroll view delegate & handlers

    @objc func changePage(pageControl: UIPageControl) {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        startTimer() // invalidate current timer and start again
    }

    // MARK: Timer

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: LayoutHelper.Onboarding.autoScrollTimeInterval, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }

    @objc private func fireTimer() {
        scrollToNext()
    }

    private func scrollToNext() {
        let nextPage = pageControl.currentPage + 1

        if pageControl.currentPage != onboardingViews.count - 1 {
            let nextPageX: CGFloat = CGFloat(nextPage) * scrollView.frame.width
            scrollView.setContentOffset(CGPoint(x: nextPageX, y: 0), animated: true)
            pageControl.currentPage = nextPage
        } else {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            pageControl.currentPage = 0
        }
    }
    
    // MARK: - Debug Menu
    
    @objc func openDebugMenu() {
        viewModel.openDebugMenu()
    }
}

extension OnboardingViewController: BinkPrimarySecondaryButtonViewDelegate {
    func binkFloatingButtonsPrimaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
        viewModel.pushToRegister()
    }

    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
        viewModel.pushToLogin()
    }
}

extension LayoutHelper {
    struct Onboarding {
        static let learningContainerHeight: CGFloat = 382
        static let learningContainerTopPadding: CGFloat = 12
        static let pageControlMinimumBottomPadding: CGFloat = -25
        static let pageControlSize: CGSize = CGSize(width: 40, height: 40)
        static let autoScrollTimeInterval: TimeInterval = 12
        static let learningViewTopPadding: CGFloat = 50
    }
}
