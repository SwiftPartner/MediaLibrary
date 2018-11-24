//
//  AssetCollectionViewCell.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/24.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import UIKit

public class AssetCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var assetImageView: UIImageView!
    @IBOutlet weak var selectionMarkView: UIButton!
    @IBOutlet weak var videoMarkView: UIImageView!

    var isVideo: Bool = false {
        didSet {
            videoMarkView.isHidden = !isVideo
        }
    }
    
    var isImageSelected: Bool = false {
        didSet {
            selectionMarkView.isSelected = isImageSelected
        }
    }
    
    var assetImage: UIImage? {
        didSet {
            assetImageView.image = assetImage
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }

}
