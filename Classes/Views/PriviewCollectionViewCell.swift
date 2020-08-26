//
//  PriviewCollectionViewCell.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/26.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import UIKit
import Photos
//import SDWebImage

public class PriviewCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var videoMarkView: UIImageView!
    private var isScaledUp = false
    
    var representedAssetIdentifier: String?
    lazy var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(gesture:)))
    lazy var tapGeture = UITapGestureRecognizer(target: self, action: #selector(didClickedCallback))
    
    var didClicked: ((PHAsset) -> Void)?
    
    var picture: UIImage? {
        didSet {
            pictureView.image = picture
        }
    }
    
    var asset : PHAsset! {
        didSet {
            pictureView.transform = .identity
            videoMarkView.isHidden = !asset.isVideo
            if asset.isVideo {
                pictureView.removeGestureRecognizer(pinchGesture)
            } else {
                pictureView.addGestureRecognizer(pinchGesture)
            }
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
//        pictureView.addGestureRecognizer(tapGeture)
    }
    
    @objc private func didPinch(gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale <= 0.2 ? 0.2 : gesture.scale
        pictureView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }

    @objc private func didClickedCallback() {
        didClicked?(asset)
    }
    
}
