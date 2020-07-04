//
//  InvertedParallaxViewCell.swift
//  PagingScrollView_Example
//
//  Created by Seyed Samad Gholamzadeh on 7/3/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class InvertedParallaxViewCell: UIView {
	
	@IBOutlet weak var parallaxImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	
	var entity: Character? {
		didSet {
			guard entity != nil else { return }
			self.parallaxImageView.image = UIImage(named: entity!.imageName)
			self.backgroundColor = UIColor(entity!.backgroundColorHex)
			self.titleLabel.text = entity?.name
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.layer.cornerRadius = 50
	}

}
