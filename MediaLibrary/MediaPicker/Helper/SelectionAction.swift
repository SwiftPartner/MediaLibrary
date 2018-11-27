//
//  SelectionAction.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/26.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import Foundation
import Photos

public enum SelectionAction {
    case done(selectedAssets: [PHAsset])
    case cancel
    case willSelect(selectedAssets: [PHAsset], willSelectedAsset: PHAsset)
    case deselect(asset: PHAsset)
}
