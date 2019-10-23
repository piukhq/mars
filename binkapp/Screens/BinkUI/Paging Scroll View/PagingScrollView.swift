//
//  PagingScrollView.swift
//  binkapp
//
//  Created by Nick Farrant on 23/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PagingScrollView: UIScrollView, UIScrollViewDelegate {

    // MARK: - Properties

    private var views: [UIView]
    private var pageControl: UIPageControl
    private var hidePageControl: Bool

    private var pageControlActivePageTint: UIColor = .lightGray {
        willSet {
            pageControl.currentPageIndicatorTintColor = newValue
        }
    }

    private var pageControlPageTint: UIColor = .white {
        willSet {
            pageControl.pageIndicatorTintColor = newValue
        }
    }

    // MARK: - Init

    init(views: [UIView], pageControl: Bool) {
        self.views = views
        self.pageControl = UIPageControl()
        self.hidePageControl = !pageControl
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    func setup() {
        guard let superview = superview else {
            fatalError("View not added to hierarchy. Superview is nil.")
        }

        bounces = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self

        frame = CGRect(x: 0, y: 0, width: superview.frame.width, height: superview.frame.height)
        contentSize = CGSize(width: frame.width * CGFloat(views.count), height: superview.frame.height)
        isPagingEnabled = true

        for i in 0..<views.count {
            views[i].frame = CGRect(x: superview.frame.width * CGFloat(i), y: 0, width: superview.frame.width, height: superview.frame.height)
            addSubview(views[i])
        }

//        setupPageControl()

//        pageControl.isHidden = hidePageControl
    }

    private func setupPageControl() {
        guard let superview = superview else {
            fatalError("View not added to hierarchy. Superview is nil.")
        }
        
        addSubview(pageControl)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        pageControl.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: 20).isActive = true
        pageControl.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -20).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        pageControl.currentPageIndicatorTintColor = pageControlActivePageTint
        pageControl.pageIndicatorTintColor = pageControlPageTint
        pageControl.numberOfPages = views.count
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(changePage(pageControl:)), for: .valueChanged)
    }

    @objc func changePage(pageControl: UIPageControl) {
        let x = CGFloat(pageControl.currentPage) * frame.size.width
        setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(contentOffset.x / frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }

    func setPageControlTint(tint: UIColor, activeTint: UIColor) {
        pageControlPageTint = tint
        pageControlActivePageTint = activeTint
    }

}
