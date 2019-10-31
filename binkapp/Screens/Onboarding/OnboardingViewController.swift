//
//  OnboardingViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 21/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet private weak var facebookPillButton: BinkPillButton!
    @IBOutlet private weak var floatingButtonsView: BinkPrimarySecondaryButtonView!

    lazy var learningContainer: UIView = {
        let container = UIView()
        return container
    }()

    private let scrollView = UIScrollView(frame: .zero)

    private let viewModel: OnboardingViewModel

    private var didLayoutSubviews = false

    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(changePage(pageControl:)), for: .valueChanged)
        return pageControl
    }()

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutSubviews {
            didLayoutSubviews = true
            configureUI()
        }
    }

    private func configureUI() {
        let view1 = OnboardingLearningView(frame: .zero)
        view1.configure(forType: .pll)
        let view2 = OnboardingLearningView(frame: .zero)
        view2.configure(forType: .wallet)
        let view3 = OnboardingLearningView(frame: .zero)
        view3.configure(forType: .barcodeOrCollect)
        let views = [
            view1,
            view2,
            view3
        ]

        facebookPillButton.configureForType(.facebook)
        facebookPillButton.addTarget(self, action: #selector(handleFacebookButtonPressed), for: .touchUpInside)

        floatingButtonsView.configure(primaryButtonTitle: viewModel.signUpWithEmailButtonText, secondaryButtonTitle: viewModel.loginWithEmailButtonText)
        floatingButtonsView.delegate = self

        facebookPillButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButtonsView.translatesAutoresizingMaskIntoConstraints = false
        learningContainer.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(learningContainer)

        let learningContainerHeightConstraint = learningContainer.heightAnchor.constraint(equalToConstant: 382)
        learningContainerHeightConstraint.priority = .init(999)

        NSLayoutConstraint.activate([
            learningContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            learningContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            learningContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            learningContainerHeightConstraint,

            floatingButtonsView.leftAnchor.constraint(equalTo: view.leftAnchor),
            floatingButtonsView.rightAnchor.constraint(equalTo: view.rightAnchor),
            floatingButtonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -LayoutHelper.PrimarySecondaryButtonView.bottomPadding),

            facebookPillButton.heightAnchor.constraint(equalToConstant: LayoutHelper.PillButton.height),
            facebookPillButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: LayoutHelper.PillButton.widthPercentage),
            facebookPillButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            facebookPillButton.bottomAnchor.constraint(equalTo: floatingButtonsView.topAnchor, constant: -LayoutHelper.PillButton.verticalSpacing),
        ])

        view.layoutIfNeeded()

        learningContainer.addSubview(scrollView)
        learningContainer.addSubview(pageControl)
        scrollView.frame = CGRect(x: 0, y: 12, width: learningContainer.frame.width, height: learningContainer.frame.height-12)
        scrollView.contentSize = CGSize(width: learningContainer.frame.width * CGFloat(views.count), height: learningContainer.frame.height-12)

        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            pageControl.bottomAnchor.constraint(lessThanOrEqualTo: facebookPillButton.topAnchor, constant: -25),
            pageControl.heightAnchor.constraint(equalToConstant: 40),
            pageControl.widthAnchor.constraint(equalToConstant: 40),
            pageControl.centerXAnchor.constraint(equalTo: learningContainer.centerXAnchor),
        ])

        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self

        scrollView.isPagingEnabled = true

        for i in 0..<views.count {
            views[i].frame = CGRect(x: learningContainer.frame.width * CGFloat(i), y: 0, width: learningContainer.frame.width, height: learningContainer.frame.height-12)
            scrollView.addSubview(views[i])
        }
    }

    // MARK: Button handlers

    @objc private func handleFacebookButtonPressed() {
        viewModel.notImplemented()
    }

    @objc func changePage(pageControl: UIPageControl) {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}

extension OnboardingViewController: BinkPrimarySecondaryButtonViewDelegate {
    func binkFloatingButtonsPrimaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
        viewModel.notImplemented()
    }

    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
        viewModel.login()
    }
}
