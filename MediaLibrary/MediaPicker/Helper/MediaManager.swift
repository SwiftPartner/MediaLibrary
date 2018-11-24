//
//  MediaManager.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/24.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import Foundation
import Photos


class MediaManager: NSObject, PHPhotoLibraryChangeObserver {
    
    static var `default` = MediaManager()
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
    }
    
    func fetchAssets(predicate: NSPredicate?) -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        options.predicate = predicate
        return PHAsset.fetchAssets(with: options)
    }
    
    func fetchSmartAlbum(predicate: NSPredicate?) -> PHFetchResult<PHAssetCollection> {
        let options = PHFetchOptions()
        options.predicate = predicate
        return PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: options)
    }
    
    func fetchUserCollection(predicate: NSPredicate?) -> PHFetchResult<PHCollection> {
        let options = PHFetchOptions()
        options.predicate = predicate
        return PHCollectionList.fetchTopLevelUserCollections(with: options)
    }
    
    public static func isAuthorized(callback: ((Bool) -> Void)?) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                MediaManager.isAuthorized(callback: callback)
            }
        case .restricted:
            fallthrough
        case .denied:
            DispatchQueue.main.async {
                callback?(false)
            }
        case .authorized:
            DispatchQueue.main.async {
                callback?(true)
            }
        }
    }
    
    func fetchCollections() {
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
}

struct AssociateKeys {
    static var kAssetsCountInCollection = "assets_count"
    static var kLastRecentAddedAsset = "last_added_asset"
}

extension PHCollection {
    var assetsCount: Int {
        set {
            objc_setAssociatedObject(self, &AssociateKeys.kAssetsCountInCollection, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.kAssetsCountInCollection) as? Int ?? 0
        }
    }
    
    var lastRecentAddedAsset: PHAsset? {
        set {
            objc_setAssociatedObject(self, &AssociateKeys.kLastRecentAddedAsset, newValue, .OBJC_ASSOCIATION_COPY)
        }
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.kLastRecentAddedAsset) as? PHAsset
        }
    }
}
