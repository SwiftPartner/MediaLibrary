//
//  AlbumsViewController.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/24.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import UIKit
import Photos

class AlbumsViewController: UIViewController {
    
    private let albumCellID = "albumCellID"
    
    @IBOutlet weak var albumsTableView: UITableView!
    
    lazy var mediaManager = MediaManager()
    lazy var imageManager = PHCachingImageManager()
    lazy var allPhotos = mediaManager.fetchAssets(predicate: nil)
    lazy var smartAlbums = mediaManager.fetchSmartAlbum(predicate: nil)
    lazy var userCollections = mediaManager.fetchUserCollection(predicate: nil)
    lazy var thumbnailImageSize = CGSize(width: 80, height: 80)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "相册"
        setupTableView()
        if allPhotos.count > 0 {
            imageManager.startCachingImages(for: [allPhotos.object(at: 0)], targetSize: CGSize(width: 80, height: 80), contentMode: .aspectFill, options: nil)
        }
        
        for i in 0 ..< smartAlbums.count {
            let collection = smartAlbums.object(at: i)
            let result = PHAsset.fetchAssets(in: collection, options: nil)
            collection.assetCollectionSubtype
            collection.assetsCount = result.count
            if result.count > 0 {
                let asset = result[0]
                collection.lastRecentAddedAsset = asset
                imageManager.startCachingImages(for: [asset], targetSize: thumbnailImageSize, contentMode: .aspectFill, options: nil)
            }
        }
        
        for i in 0 ..< userCollections.count {
            let collection = userCollections.object(at: i) as! PHAssetCollection
            let result = PHAsset.fetchAssets(in: collection, options: nil)
            if result.count > 0 {
                let asset = result[0]
                collection.assetsCount = result.count
                collection.lastRecentAddedAsset = asset
                imageManager.startCachingImages(for: [asset], targetSize: CGSize(width: 80, height: 80), contentMode: .aspectFill, options: nil)
            }
        }
        self.albumsTableView.reloadData()
    }
    
    private func setupTableView() {
        albumsTableView.register(UINib(nibName: "AlbumTableViewCell", bundle: nil), forCellReuseIdentifier: albumCellID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAuthorized()
        print("\(#function)")
    }
}

// MARK: 访问相册权限受理
extension AlbumsViewController {
    private func isAuthorized() {
        MediaManager.isAuthorized { [weak self] authorized in
            if authorized {
                self?.albumsTableView.reloadData()
                return
            }
            self?.showRequestAuthorizationDialog()
        }
    }
    
    private func showRequestAuthorizationDialog() {
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as! String
        let alertController = UIAlertController(title: "无法访问相册", message: "\(appName)无权访问您的相册,请打开系统设置页面，按照如下步骤操作【隐私 - 照片 - \(appName) - 读取和写入】以授权", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "授权", style: .default, handler: nil)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: UITableDataSource & UITableViewDelegate
extension AlbumsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + smartAlbums.count + userCollections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let albumCell = tableView.dequeueReusableCell(withIdentifier: albumCellID) as! AlbumTableViewCell
        var asset: PHAsset?
        switch indexPath.row {
        case 0:
            albumCell.nameLabel.text = NSLocalizedString("All Photos", comment: "")
            albumCell.assetsCountLabel.text = "(\(allPhotos.count))"
            if allPhotos.count > 0 {
                asset = allPhotos.object(at: 0)
            }
        case 1 ..< 1 + smartAlbums.count:
            let album = smartAlbums[indexPath.row - 1]
            albumCell.nameLabel.text = album.localizedTitle
            albumCell.assetsCountLabel.text =  "(\(album.assetsCount))"
            asset = album.lastRecentAddedAsset
            print("Smart Album: \(album.localizedTitle)")
        default:
            let collection = userCollections[indexPath.row - 1 - smartAlbums.count]
            albumCell.nameLabel.text = collection.localizedTitle
            albumCell.assetsCountLabel.text = "(\(collection.assetsCount))"
            asset = collection.lastRecentAddedAsset
            print("UserCollection: \(collection.localizedTitle)")
        }
        guard let notNilAsset = asset else {
            albumCell.coverImageView.image = nil
            return albumCell
        }
        albumCell.representedAssetIdentifier = notNilAsset.localIdentifier
        imageManager.requestImage(for: notNilAsset, targetSize: thumbnailImageSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if albumCell.representedAssetIdentifier == notNilAsset.localIdentifier {
                albumCell.coverImageView.image = image
            }
        })
        return albumCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= 1 && indexPath.row < 1 + smartAlbums.count {
             let album = smartAlbums[indexPath.row - 1]
            if album.localizedTitle == "所有照片" {
                return 0
            }
        }
        return 50
    }
    
}
