//
//  ParallaxViewController.swift
//  PagingScrollView_Example
//
//  Created by Seyed Samad Gholamzadeh on 5/5/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SwiftyPagingScrollView

class ParallaxViewController: UIViewController {
	
	var pagingScrollView: PagingScrollView!
	
	var list: [Character] = []
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.pagingScrollView = PagingScrollView()
		let screenWidth = 300
		let screenHeihgt = 300
		
		let pageWidth = min(screenWidth, screenHeihgt) - 100
		let pageSize = CGSize(width: pageWidth, height: pageWidth)
		
		self.pagingScrollView.pageSize = pageSize
		self.pagingScrollView.pageSpace = 10
		self.pagingScrollView.register(UINib(nibName: "ParallaxViewCell", bundle: nil), forPageResueIdentifier: "pageView")
		self.pagingScrollView.register(UINib(nibName: "InvertedParallaxViewCell", bundle: nil), forPageResueIdentifier: "InvertPageView")

		self.pagingScrollView.pagingScrollViewDataSource = self
		self.pagingScrollView.pagingScrollViewDelegate = self
		self.pagingScrollView.scrollDelegate = self
		self.pagingScrollView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
		self.view.addSubview(self.pagingScrollView)
		
		// Do any additional setup after loading the view.
		DispatchQueue.global().async {
			
			guard let url = Bundle.main.url(forResource: "Characters", withExtension: "json") else { return }
			
			do {
				let jsonData = try Data(contentsOf: url)
				let list = try JSONDecoder().decode([Character].self, from: jsonData)
				self.list = list
				DispatchQueue.main.async {
					self.pagingScrollView.reloadData()
				}
				
			} catch {
				print("error is \(error)")
			}
			
		}
		
	}
	
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		self.pagingScrollView.updatePagesLayout(animated: true)
	}
	
	
}

extension ParallaxViewController: PagingScrollViewDataSource, PagingScrollViewDelegate {
	
	func numberOfPages() -> Int {
		self.list.count
	}
	
	func pagingScrollView(_ pagingScrollView: PagingScrollView, pageAt index: Int) -> UIView {
		
		let entity = self.list[index]

		if index%2 == 0 {
			let page = pagingScrollView.dequeueReusablePage(withIdentifier: "pageView", for: index) as! ParallaxViewCell
			
			page.entity = entity
			return page

		}
		else {
			let page = pagingScrollView.dequeueReusablePage(withIdentifier: "InvertPageView", for: index) as! InvertedParallaxViewCell
			
			page.entity = entity
			return page

		}
		
	}
	
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didSelectPageAt index: Int) {
		let page = pagingScrollView.pageForIndex(index) as? ParallaxViewCell
		let entity = self.list[index]
		print("Page did select with index \(index) and title \(entity.name)")
	}
	
	
}


extension ParallaxViewController: PagingScrollViewScrollDelegate {
	
	func pagingScrollViewDidEndDecelerating(_ pagingScrollView: PagingScrollView) {
		print("current index is \(pagingScrollView.currentIndex)")
	}
	
}
