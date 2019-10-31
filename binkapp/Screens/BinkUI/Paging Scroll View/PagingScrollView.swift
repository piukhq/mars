//
//  PagingScrollView.swift
//  binkapp
//
//  Created by Nick Farrant on 23/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PagingScrollView: UIView, UIScrollViewDelegate {

    lazy var container: UIView = {
        let container = UIView()
        return container
    }()

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

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

    func configure() {
        let views = [
            UIView()
        ]

        layoutIfNeeded()

        container.addSubview(scrollView)
        container.addSubview(pageControl)
        scrollView.frame = CGRect(x: 0, y: 0, width: container.frame.width, height: container.frame.height)
        scrollView.contentSize = CGSize(width: container.frame.width * CGFloat(views.count), height: container.frame.height)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
            pageControl.widthAnchor.constraint(equalToConstant: 50),
            pageControl.centerXAnchor.constraint(equalTo: container.centerXAnchor),
        ])

        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self

        scrollView.isPagingEnabled = true

        for i in 0..<views.count {
            views[i].frame = CGRect(x: container.frame.width * CGFloat(i), y: 0, width: container.frame.width, height: container.frame.height)
            scrollView.addSubview(views[i])
        }
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
