//
//  Character.swift
//  PagingScrollView_Example
//
//  Created by Seyed Samad Gholamzadeh on 5/5/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation


struct Character: Decodable {
	
	let name: String
	let imageName: String
	let backgroundColorHex: String
	
	enum CodingKeys: String, CodingKey {
		case name, imageName = "image", backgroundColorHex = "background_color"
	}

}
