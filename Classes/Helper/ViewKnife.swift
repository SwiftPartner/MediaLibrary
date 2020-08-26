//
//  ViewKnife.swift
//  MediaLibraryExample
//
//  Created by Ryan on 2018/11/27.
//  Copyright © 2018 Runryan. All rights reserved.
//

import UIKit

public extension UIView {
    @IBInspectable var spCornerRadius: CGFloat {
        set {
            makeCorners(cornerRadius: newValue)
        }
        get {
            return layer.cornerRadius
        }
    }
    
    func makeCorners(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
}
