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
    @IBOutlet weak var coverView: UIView!
    
    var representedAssetIdentifier: String?

    var isVideo: Bool = false {
        didSet {
            videoMarkView.isHidden = !isVideo
        }
    }
    
    var selectedOrder: String? = "1" {
        didSet {
            if !isImageSelected {
                selectionMarkView.setTitle(nil, for: .normal)
            } else {
                selectionMarkView.setTitle(selectedOrder, for: .normal)
            }
        }
    }
    
    var isImageSelected: Bool = false {
        didSet {
//            selectionMarkView.isSelected = isImageSelected
            selectionMarkView.backgroundColor = isImageSelected ? .red : .clear
            selectedOrder = isImageSelected ? selectedOrder : nil
            let bundle = Bundle(for: AssetsViewController.self)
            let image = isImageSelected ? UIImage() : UIImage(named: "pic_unselect", in: bundle, compatibleWith: nil)
            selectionMarkView.setImage(image, for: .normal)
            coverView.isHidden = !isImageSelected
        }
    }
    
    var assetImage: UIImage? {
        didSet {
            assetImageView.image = assetImage
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        selectionMarkView.makeCorners(cornerRadius: 10)
    }

}
