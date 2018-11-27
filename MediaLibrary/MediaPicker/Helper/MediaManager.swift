//
//  MediaManager.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/24.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import Foundation
import Photos
//import SwiftHash
//import SDWebImage

public class MediaManager: NSObject, PHPhotoLibraryChangeObserver {
    
    static var `default` = MediaManager()
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
    }
    
    public func fetchAssets(predicate: NSPredicate?) -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        options.predicate = predicate
        return PHAsset.fetchAssets(with: options)
    }
    
    public func fetchSmartAlbum(predicate: NSPredicate?) -> PHFetchResult<PHAssetCollection> {
        let options = PHFetchOptions()
        options.predicate = predicate
        return PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: options)
    }
    
    public func fetchUserCollection(predicate: NSPredicate?) -> PHFetchResult<PHCollection> {
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
    
    public func fetchCollections() {
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
}

public struct AssociateKeys {
    static var kAssetsCountInCollection = "assets_count"
    static var kLastRecentAddedAsset = "last_added_asset"
    static var kIsAssetSelected = "is_asset_selected"
    static var kAssetSelectionOrder = "asset_selection_order"
    static var kCacheURL = "cache_url"
}

public extension PHCollection {
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

public extension PHAsset {
    public var isVideo: Bool {
        return mediaType == .video
    }
}

// MARK: 与AssetsViewController相关的属性
public extension PHAsset {
    public var isSelected: Bool {
        set {
            objc_setAssociatedObject(self, &AssociateKeys.kIsAssetSelected, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.kIsAssetSelected) as? Bool ?? false
        }
    }
    
    public var selectionOrder: Int {
        set {
            objc_setAssociatedObject(self, &AssociateKeys.kAssetSelectionOrder, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.kAssetSelectionOrder) as? Int ?? 1
        }
    }
}

// MARK: 与PreviewViewController相关的属性
//public extension PHAsset {
//    public var cacheURL: URL? {
//        let fileName = MD5(localIdentifier)
//        var imageFileURL = URL(string: NSTemporaryDirectory())
//        imageFileURL?.appendPathComponent(fileName)
//        return imageFileURL
//    }
//    
//    public var cacheKey: String? {
//        return SDWebImageManager.shared().cacheKey(for: cacheURL)
//    }
//}

public protocol ConvertableFetchResult {
    func allObjects<T: AnyObject>() -> [T]
}

