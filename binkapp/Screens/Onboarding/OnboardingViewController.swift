//
//  OnboardingViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 21/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import AuthenticationServices

class OnboardingViewController: BinkViewController, UIScrollViewDelegate {
    private let viewModel = OnboardingViewModel()
    private var didLayoutSubviews = false
    private var timer: Timer?
    
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
    
    private lazy var signInWithAppleEnabled: Bool = {
        return APIConstants.isProduction && Current.isReleaseTypeBuild
    }()

    private lazy var facebookButton: BinkButton = {
        return BinkButton(type: .pill(.facebook)) { [weak self] in
            self?.handleFacebookButtonPressed()
        }
    }()

    private lazy var registerButton: BinkButton = {
        return BinkButton(type: .gradient, title: viewModel.signUpWithEmailButtonText) { [weak self] in
            self?.viewModel.pushToRegister()
        }
    }()

    private lazy var loginButton: BinkButton = {
        return BinkButton(type: .plain, title: viewModel.loginWithEmailButtonText) { [weak self] in
            self?.viewModel.pushToLogin()
        }
    }()

    lazy var signInWithAppleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .continue, style: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.cornerRadius = 27.5
        return button
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
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        onboardingView1.configure(forType: .pll)
        onboardingView2.configure(forType: .wallet)
        onboardingView3.configure(forType: .barcodeOrCollect)
    }

    private func setLayout() {
        let learningContainerHeightConstraint = learningContainer.heightAnchor.constraint(equalToConstant: LayoutHelper.Onboarding.learningContainerHeight)
        learningContainerHeightConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            learningContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutHelper.Onboarding.learningContainerTopPadding),
            learningContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            learningContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            learningContainerHeightConstraint,

            pageControl.topAnchor.constraint(equalTo: learningContainer.bottomAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: LayoutHelper.Onboarding.pageControlSize.height),
            pageControl.widthAnchor.constraint(equalToConstant: LayoutHelper.Onboarding.pageControlSize.width),
            pageControl.centerXAnchor.constraint(equalTo: learningContainer.centerXAnchor)
        ])

        footerButtons = [facebookButton, registerButton, loginButton]
    }

    @objc private func handleAppleIdRequest() {
        BinkAnalytics.track(OnboardingAnalyticsEvent.start(journey: .apple))
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func configureUI() {
        if signInWithAppleEnabled, let buttonsView = footerButtonsView {
            signInWithAppleButton.layer.applyDefaultBinkShadow()
            buttonsView.insertAdditionalViews([signInWithAppleButton])
            NSLayoutConstraint.activate([
                signInWithAppleButton.heightAnchor.constraint(equalToConstant: 55),
                signInWithAppleButton.widthAnchor.constraint(equalTo: buttonsView.widthAnchor, multiplier: LayoutHelper.PillButton.widthPercentage),
                buttonsView.topAnchor.constraint(greaterThanOrEqualTo: pageControl.bottomAnchor)
            ])
            signInWithAppleButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        } else if let buttonsView = footerButtonsView {
            NSLayoutConstraint.activate([
                buttonsView.topAnchor.constraint(greaterThanOrEqualTo: pageControl.bottomAnchor)
            ])
        }

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

    private func handleFacebookButtonPressed() {
        guard Current.apiClient.networkIsReachable else {
            let alert = ViewControllerFactory.makeNoConnectivityAlertController()
            let navigationRequest = AlertNavigationRequest(alertController: alert)
            Current.navigate.to(navigationRequest)
            return
        }
    
        BinkAnalytics.track(OnboardingAnalyticsEvent.start(journey: .facebook))
        
        FacebookLoginController.login(with: self, onSuccess: { [weak self] facebookRequest in
            // If we have no email address, push them onto the add email screen
            guard facebookRequest.email != nil else {
                self?.viewModel.pushToAddEmail(request: facebookRequest)
                return
            }
            
            self?.viewModel.pushToSocialTermsAndConditions(requestType: .facebook(facebookRequest))
        }) { [weak self] isCancelled in
            self?.showError(isCancelled)
        }
    }
    
    func showError(_ isCancelled: Bool) {
        let message = isCancelled ? viewModel.facebookLoginCancelledText : viewModel.facebookLoginErrorText
        
        let alert = BinkAlertController(title: viewModel.facebookLoginErrorTitle, message: message, preferredStyle: .alert)
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
            let nextPageX = CGFloat(nextPage) * scrollView.frame.width
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

extension LayoutHelper {
    enum Onboarding {
        static let learningContainerHeight: CGFloat = 382
        static let learningContainerTopPadding: CGFloat = 12
        static let pageControlMinimumBottomPadding: CGFloat = -25
        static let pageControlSize = CGSize(width: 40, height: 40)
        static let autoScrollTimeInterval: TimeInterval = 12
        static let learningViewTopPadding: CGFloat = 50
    }
}

// MARK: - Sign in with Apple

extension OnboardingViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = view.window else {
            fatalError("View has no window")
        }
        return window
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        guard let authCodeData = appleIDCredential.authorizationCode else { return }
        let authCodeString = String(decoding: authCodeData, as: UTF8.self)
        signInWithApple(authCode: authCodeString)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("")
    }
    
    // TODO: // Move to user service in future ticket. All login type requests should reuse the same code where possible
    private func signInWithApple(authCode: String) {
        let loginRequest = SignInWithAppleRequest(authorizationCode: authCode)
        viewModel.pushToSocialTermsAndConditions(requestType: .apple(loginRequest))
    }
    
    private func handleLoginError() {
        Current.userManager.removeUser()
        let navigationRequest = AlertNavigationRequest(alertController: ViewControllerFactory.makeOkAlertViewController(title: "error_title".localized, message: "login_error".localized))
        Current.navigate.to(navigationRequest)
    }
}
