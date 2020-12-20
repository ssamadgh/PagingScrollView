//
//  PagingScrollView.swift
//  Tutee
//
//  Created by Seyed Samad Gholamzadeh on 1/2/20.
//  Copyright © 2020 Sishemi. All rights reserved.
//

import UIKit

open class PagingScrollView: UIScrollView, UIScrollViewDelegate {
	
	enum ViewType {
		case pageClass(AnyClass), nib(UINib)
	}
	
	var typeDic: [String : ViewType] = [:]
	
	public typealias Page = UIView
	
	public weak var pagingScrollViewDataSource: PagingScrollViewDataSource?
	public weak var pagingScrollViewDelegate: PagingScrollViewDelegate?
	public weak var scrollDelegate: PagingScrollViewScrollDelegate?
	
	public var pageSize: CGSize = .zero {
		didSet {
			self.calculateNumberOfVisiblePages()
		}
	}
	
	public var pageSpace: CGFloat = 0
	
	public var numberOfVisiblePages: Int!
    public private(set) var visiblePages: Set<Page> = []

	var recycledPages: Set<Page> = []
	var pagesIndex: [Page : Int] = [:]
	
	public private(set) var currentIndex: Int = 0
	
	public private(set) lazy var currentPage: Page = {
		return self.pageForIndex(currentIndex)!
	}()
	
    private var pagePadding: CGFloat { return pageSpace/2 }

	private var screenWidth: CGFloat = {
		return UIScreen.main.bounds.width
	}()
	
	private var pagesCount: Int {
		self.pagingScrollViewDataSource?.numberOfPages() ?? 0
	}
	
	var singleTap: UITapGestureRecognizer!
	
	override open func didMoveToSuperview() {
		self.frame = self.frameForPagingScrollView()
		self.contentSize = self.contentSizeForPagingScrollView()
		self.contentOffset.x = self.offsetFor(index: self.currentIndex).x
		self.calculateNumberOfVisiblePages()
		self.tilePages()
	}
	
	public override init(frame: CGRect) {
		super.init(frame: .zero)
		
		showsVerticalScrollIndicator = false
		showsHorizontalScrollIndicator = false
		isPagingEnabled = true
		if #available(iOS 11.0, *) {
			contentInsetAdjustmentBehavior = .never
		} else {
			// Fallback on earlier versions
			
		}
		clipsToBounds = false
		delegate = self
		self.singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
		self.singleTap.cancelsTouchesInView = false
		self.addGestureRecognizer(self.singleTap)
	}
	
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func frameForPagingScrollView() -> CGRect {
		guard let superView = self.superview else { return .zero }
		
		let padding = self.pagePadding
		let size = self.pageSize
		let superViewFrame = superView.bounds
		var frame = CGRect.zero
		
		frame.size = size
		
		frame.origin.x = (superViewFrame.width - frame.width)/2
		frame.origin.y = (superViewFrame.height - frame.height)/2
		
		frame.origin.x -= padding
		frame.size.width += 2*padding
		return frame
	}
	
	private func contentSizeForPagingScrollView() -> CGSize {
		let bounds = self.bounds
		return CGSize(width: bounds.size.width*CGFloat(self.pagesCount), height: bounds.size.height)
	}
	
	open func calculateNumberOfVisiblePages() {
		let superViewWidth = superview?.bounds.width ?? 0
		let pageWidth = self.pageSize.width
		guard pageWidth != 0 else {
			fatalError("Please set a non zero page size")
		}
		let numberOfVisiblePages = Int(ceil((superViewWidth/pageWidth)*3))
		self.numberOfVisiblePages = max(3, numberOfVisiblePages)
	}
	
	public func frameForPage(at index: Int) -> CGRect {
		let padding = self.pagePadding
		let bounds = self.bounds
		var pageFrame = bounds
		pageFrame.size = pageSize
		pageFrame.origin.x = padding + (bounds.size.width*CGFloat(index))
		
		return pageFrame
	}
	
	public func scrollToPage(at index: Int, animated: Bool) {
		self.currentIndex = index
		self.setContentOffset(offsetFor(index: index), animated: animated)
	}
	
	//MARK: - Tiling and page configuration
	private func tilePages() {
		guard let superView = self.superview else { return }
		guard let numberOfPages = self.pagingScrollViewDataSource?.numberOfPages(), numberOfPages > 0 else { return }
		// Calculate which pages should now be visible
		let visibleBounds = self.bounds
		let pageWidth = pageSize.width
		let padding: CGFloat = (superView.bounds.width - pageWidth)/2
		
		var firstNeededPageIndex: Int = max(0, Int(floor((visibleBounds.minX - padding)/pageWidth)))
		var lastNeededPageIndex: Int = max(0, Int(floor((visibleBounds.maxX + padding)/pageWidth)))
		
		firstNeededPageIndex = max(firstNeededPageIndex, 0)
		lastNeededPageIndex = min(lastNeededPageIndex, max(0, self.pagesCount - 1))
		
		let diff = lastNeededPageIndex - firstNeededPageIndex
		if diff < (self.numberOfVisiblePages - 1) {
			
			var diff = (self.numberOfVisiblePages - 1) - diff
			var firstTurn = true
			
			while diff > 0 {
				if firstTurn, firstNeededPageIndex > 0 {
					firstNeededPageIndex = max(0, firstNeededPageIndex - 1)
					firstTurn.toggle()
				}
				else {
					lastNeededPageIndex = min(lastNeededPageIndex + 1, max(0, self.pagesCount - 1))
					firstTurn.toggle()
				}
				diff -= 1
			}
		}
		
		//Recycle no longer needs pages
		for page in self.visiblePages {
			
			if let pageIndex = pagesIndex[page], pageIndex < firstNeededPageIndex || pageIndex > lastNeededPageIndex {
				//            if page.index < firstNeededPageIndex || page.index > lastNeededPageIndex {
				self.recycledPages.insert(page)
				page.removeFromSuperview()
			}
		}
		self.visiblePages.subtract(self.recycledPages)
		
		//add missing pages
		for index in firstNeededPageIndex...lastNeededPageIndex {
			if !self.isDisplayingPage(forIndex: index) {
				guard let page = self.pagingScrollViewDataSource?.pagingScrollView(self, pageAt: index) else {
					fatalError("You should implement PagingScrollViewDataSource methods")
				}
				
				pagesIndex[page] = index
				page.frame = self.frameForPage(at: index)

				self.addSubview(page)
				self.visiblePages.insert(page)
				
			}
		}
		
		applyParallaxScrollingEffect()
		
	}
	
	func applyParallaxScrollingEffect() {
		guard let superView = self.superview,
			let screenWidth = self.window?.bounds.width
			else { return }
		let scrollViewWidth = self.bounds.width
		for page in self.visiblePages {
			let center = CGPoint(x: page.frame.midX, y: page.frame.midY)
			let pageCenterInScreenViewCoordinate = self.convert(center, to: superView)
			let pageX = pageCenterInScreenViewCoordinate.x
			let value = (pageX - (screenWidth*0.5))/scrollViewWidth
			
			(page as? ParallaxScrollViewDelegate)?.didChangeParalex(to: value)
		}
		
	}
	
	//MARK: - ScrollView delegate methods
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.tilePages()
		
		self.scrollDelegate?.pagingScrollViewDidScroll(self)
	}
	
	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.scrollDelegate?.pagingScrollViewWillBeginDragging(self)
	}
	public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		self.scrollDelegate?.pagingScrollViewWillEndDragging(self, withVelocity: velocity, targetContentOffset: targetContentOffset)
	}
	
	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		self.scrollDelegate?.pagingScrollViewDidEndDragging(self, willDecelerate: decelerate)
	}
	
	public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		self.scrollDelegate?.pagingScrollViewWillBeginDecelerating(self)
	}
	
	
	
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let width = self.bounds.width
		let currentIndex = (self.contentOffset.x + width*0.5)/width
		self.currentIndex = Int(currentIndex)
		self.currentPage = self.pageForIndex(self.currentIndex)!
		
		scrollDelegate?.pagingScrollViewDidEndDecelerating(self)
	}
	
	
	public func isDisplayingPage(forIndex index: Int) -> Bool {
		for page in self.visiblePages {
			if let pageIndex = pagesIndex[page], pageIndex == index {
				return true
			}
		}
		return false
	}

	public func register(_ pageClass: AnyClass?, forPageResueIdentifier identifier: String) {
		self.typeDic[identifier] = pageClass == nil ? nil : .pageClass(pageClass!)
	}
	
	public func register(_ nib: UINib?, forPageResueIdentifier identifier: String) {
		self.typeDic[identifier] = nib == nil ? nil : .nib(nib!)
	}

	public func dequeueReusablePage(withIdentifier identifier: String) -> Page {
		privateDequeueReusablePage(withIdentifier: identifier, for: nil)
	}
	
	public func dequeueReusablePage(withIdentifier identifier: String, for index: Int) -> Page {
		privateDequeueReusablePage(withIdentifier: identifier, for: index)
	}
	
	private func privateDequeueReusablePage(withIdentifier identifier: String, for index: Int?) -> Page {
		let page: Page
		
		if let recyclePage = self.dequeueRecycledPage(for: index) {
			page = recyclePage
		}
		else {
			
			if let type = typeDic[identifier] {
				
				switch type {
				case .pageClass(let pageClass):
					let classPage = (pageClass as! Page.Type).init()
					page = classPage

				case .nib(let nib):
					guard let nibPage = nib.instantiate(withOwner: nil, options: nil).first as? Page else {
						fatalError("nib file Class Should be subclass of `UIView`")
					}
					
					page = nibPage

				}
				
			}
			else {
				page = Page()
			}
						
		}
		
		page.frame.size = pageSize

		return page
	}
	
	private func dequeueRecycledPage(for index: Int? = nil) -> Page? {
		
		if let page = index == nil ? self.recycledPages.first : self.recycledPages.first(where: { pagesIndex[$0] == index }) {
			self.recycledPages.remove(page)
			return page
		}
		
		return nil
	}
	
	public func indexForPage(_ page: Page) -> Int? {
		let width = self.bounds.width
		let index = Int((page.frame.minX + page.frame.width*0.5)/width)
		return index
	}
	
	public func pageForIndex(_ index: Int) -> Page? {
		self.visiblePages.first { (page) -> Bool in
			return pagesIndex[page] == index
		}
	}
	
	@objc func handleSingleTap(_ gesture: UITapGestureRecognizer) {
		for page in self.visiblePages {
			let pageFrame = page.frame
			let gesturePoint = gesture.location(in: gesture.view)
			if pageFrame.contains(gesturePoint), let index = indexForPage(page) {
				self.pagingScrollViewDelegate?.pagingScrollView(self, didSelectPageAt: index)
				return
			}
		}
	}
	
	func offsetFor(index: Int) -> CGPoint {
		let yOffset = self.contentOffset.y
		let width = self.bounds.width
		
		let xOffset = CGFloat(index)*width
		return CGPoint(x: xOffset, y: yOffset)
	}
	
	public func reloadData() {
		self.visiblePages.forEach { $0.removeFromSuperview() }
		self.visiblePages.removeAll(keepingCapacity: true)
		let numberOfPages = self.pagingScrollViewDataSource?.numberOfPages() ?? 0
		let currentIndex = self.currentIndex < numberOfPages ? self.currentIndex : max(0, numberOfPages - 1)
		self.contentSize = self.contentSizeForPagingScrollView()
		self.contentOffset.x = self.offsetFor(index: currentIndex).x
		self.tilePages()
	}
	
	public func updatePagesLayout(animated: Bool) {
		
		func updateLayout() {
			self.frame = self.frameForPagingScrollView()
			self.contentSize = self.contentSizeForPagingScrollView()
			self.contentOffset.x = self.offsetFor(index: self.currentIndex).x
			self.calculateNumberOfVisiblePages()
			for page in self.visiblePages {
				if let index = self.indexForPage(page) {
					page.frame = self.frameForPage(at: index)
				}
			}
			self.tilePages()
		}
		
		if animated {
			UIView.animate(withDuration: 0.5) {
				updateLayout()
			}
		}
		else {
			updateLayout()
		}
		
	}
	
	override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let interact = super.point(inside: point, with: event)
		if !interact {
			let superViewPoint = self.convert(point, to: self.superview)
			return self.superview?.frame.contains(superViewPoint) ?? false
		}
		
		return interact
	}
	
}
