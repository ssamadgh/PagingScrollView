//
//  PagingScrollViewDelegate.swift
//  Tutee
//
//  Created by Seyed Samad Gholamzadeh on 1/2/20.
//  Copyright © 2020 Sishemi. All rights reserved.
//

import UIKit


public protocol PagingScrollViewDelegate: class {
    func pagingScrollView(_ pagingScrollView: PagingScrollView, didSelectPageAt index: Int)
}

public protocol PagingScrollViewDataSource: class {
    
    func numberOfPages() -> Int
    
    func pagingScrollView(_ pagingScrollView: PagingScrollView, pageAt index: Int) -> UIView
}

public protocol PagingScrollViewScrollDelegate: class {
	
	func pagingScrollViewDidScroll(_ pagingScrollView: PagingScrollView)
	func pagingScrollViewWillBeginDragging(_ scrollView: PagingScrollView)
	func pagingScrollViewWillEndDragging(_ scrollView: PagingScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
	func pagingScrollViewDidEndDragging(_ scrollView: PagingScrollView, willDecelerate decelerate: Bool)
	func pagingScrollViewWillBeginDecelerating(_ scrollView: PagingScrollView)
	func pagingScrollViewDidEndDecelerating(_ pagingScrollView: PagingScrollView)
}


public extension PagingScrollViewScrollDelegate {
    
    func pagingScrollViewDidScroll(_ pagingScrollView: PagingScrollView) { }
	func pagingScrollViewWillBeginDragging(_ scrollView: PagingScrollView) {}
	func pagingScrollViewWillEndDragging(_ scrollView: PagingScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {}
	func pagingScrollViewDidEndDragging(_ scrollView: PagingScrollView, willDecelerate decelerate: Bool) {}
	func pagingScrollViewWillBeginDecelerating(_ scrollView: PagingScrollView) {}
    func pagingScrollViewDidEndDecelerating(_ pagingScrollView: PagingScrollView) { }
}
