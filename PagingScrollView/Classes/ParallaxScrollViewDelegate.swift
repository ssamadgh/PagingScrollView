//
//  ParallaxScrollViewDelegate.swift
//  Tutee
//
//  Created by Seyed Samad Gholamzadeh on 1/3/20.
//  Copyright © 2020 Sishemi. All rights reserved.
//

import UIKit

public protocol ParallaxScrollViewDelegate {
    
    /// The fraction of parallax Change
    /// - Parameter value: This value is in range of -1 to 1.
    /// Use this value to add parallax effects to your view.
    /// This value if the view be in the end of left edge is -1,
    ///  if the view be in the end of right edge is 1 and if the view be in the center is 0.
    func didChangeParalex(to value: CGFloat)
}
