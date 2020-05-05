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
		let screenWidth = UIScreen.main.bounds.width
		let screenHeihgt = UIScreen.main.bounds.height
		
		let pageWidth = min(screenWidth, screenHeihgt) - 100
		let pageSize = CGSize(width: pageWidth, height: pageWidth)
		
		self.pagingScrollView.pageSize = pageSize
		self.pagingScrollView.pageSpace = 10
		self.pagingScrollView.registerForPageResue(UINib(nibName: "ParallaxViewCell", bundle: nil))
		self.pagingScrollView.pagingScrollViewDataSource = self
		self.pagingScrollView.pagingScrollViewDelegate = self
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
		let page = pagingScrollView.dequeueReusablePage(for: index) as! ParallaxViewCell
		
		let entity = self.list[index]
		page.entity = entity
		
		return page
	}
	
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didSelectPageAt index: Int) {
		let page = pagingScrollView.pageForIndex(index) as! ParallaxViewCell
		let entity = self.list[index]
		print("Page did select with index \(index) and title \(entity.name)")
	}
	
	
}
