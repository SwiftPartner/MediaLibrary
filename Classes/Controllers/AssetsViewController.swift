//
//  AssetsViewController.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/24.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import UIKit
import Photos

open class AssetsViewController: UIViewController {
    
    private let kAssetCellID = "asset_cell_id"
    weak var previewButton: UIBarButtonItem!
    weak var doneButton: UIBarButtonItem!
    var firstShow = true
    
    public struct Configuration {
        var numberOfCollums = 4
        var rowsMargin = CGFloat(5)
        var collumnMargin = CGFloat(5)
        var contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
    }
    
    @IBOutlet weak var assetCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    public static var configuration = Configuration()
    private lazy var mediaManager = MediaManager()
    private lazy var imageManager = PHCachingImageManager()
    public var fetchResult: PHFetchResult<PHAsset>!
    public var selectAssetCallback: ImagePickerViewController.AssetsSelectionCallback?
    private lazy var selectedAssets = [PHAsset]()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        //        title = "照片"
        setupCollectionView()
//
        if fetchResult == nil {
            fetchResult = mediaManager.fetchAssets(predicate: nil)
            let assets = PHFetchResultHelper.makeObjectsInArray(fetchResult: fetchResult)
            imageManager.startCachingImages(for: assets, targetSize: CGSize(width: 120, height: 120), contentMode: .aspectFill, options: nil)
        }
        
        let cancelButton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let previewButton = UIBarButtonItem(title: "预览", style: .plain, target: self, action: #selector(preview(_:)))
        let spacingItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(done(_:)))
        if firstShow {
            doneButton.isEnabled = false
            previewButton.isEnabled = false
            firstShow = false
        }
        toolbarItems = [previewButton, spacingItem, doneButton]
        navigationController?.setToolbarHidden(false, animated: false)
        self.previewButton = previewButton
        self.doneButton = doneButton
        
        resetSelectionOrder()
        reloadData()
    }
    
    private func setupCollectionView() {
        
        let bundle = Bundle(for: AssetsViewController.self)
        assetCollectionView.register(UINib(nibName: "AssetCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: kAssetCellID)
        let configuration = AssetsViewController.configuration
        assetCollectionView.contentInset = configuration.contentInset
        
        let allMargins = configuration.contentInset.left + configuration.contentInset.right
            + CGFloat(configuration.numberOfCollums - 1) * configuration.collumnMargin
        let itemHeight = (UIScreen.main.bounds.size.width - allMargins) / CGFloat(configuration.numberOfCollums)
        
        flowLayout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        flowLayout.minimumLineSpacing = configuration.rowsMargin
        flowLayout.minimumInteritemSpacing = configuration.collumnMargin
        assetCollectionView.reloadData()
    }
    
    // MARK: 预览
    @objc private func preview(_ sender: Any) {
        //        print("预览")
        let bundle = Bundle(for: AssetsViewController.self)
        let previewController = PreviewViewController(nibName: "PreviewViewController", bundle: bundle)
        previewController.selectAssetCallback = { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.resetSelectionOrder()
            strongSelf.reloadData()
            strongSelf.done(strongSelf.doneButton)
        }
        previewController.selectedAssets = selectedAssets
        navigationController?.pushViewController(previewController, animated: true)
    }
    
    // MARK: 完成
    @objc private func done(_ sender: Any) {
        _ = selectAssetCallback?(.done(selectedAssets: selectedAssets))
    }
    
    // MARK: 操作取消
    @objc func cancel() {
        print("\(self) \(#function) \(#line)")
        _ = selectAssetCallback?(.cancel)
    }
    
    deinit {
        imageManager.stopCachingImagesForAllAssets()
        print("我被关闭了，哈哈哈")
    }
    
    // MARK: 取消选中Asset
    func unselectAsset(asset: PHAsset) {
        let index = selectedAssets.firstIndex(of: asset)!
        asset.isSelected = false
        selectedAssets.remove(at: index)
        resetSelectionOrder()
        reloadData()
    }
    
    // MARK: 选中Asset
    func selectAsset(asset: PHAsset) {
        asset.isSelected = true
        selectedAssets.append(asset)
        resetSelectionOrder()
        reloadData()
    }
}

extension AssetsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kAssetCellID, for: indexPath) as! AssetCollectionViewCell
        let asset = fetchResult![indexPath.item]
        cell.isVideo = asset.mediaType == .video
        cell.selectedOrder = "\(asset.selectionOrder + 1)"
        cell.isImageSelected = asset.isSelected
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: nil) { (image, info) in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.assetImage = image
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectAssetCallback == nil {
            fatalError("\(#function) \(#line) selectAssetCallback不能为nil")
        }
        print("选择了第\(indexPath.item)行")
        let asset = fetchResult![indexPath.item]
        if asset.isSelected {
            asset.isSelected = false
            unselectAsset(asset: asset)
            return
        }
        if selectAssetCallback?(.willSelect(selectedAssets: selectedAssets, willSelectedAsset: asset))?.isAssetSelectable == false {
            print("不能选择……")
            return
        }
        asset.isSelected = true
        selectAsset(asset: asset)
    }
    
    // MARK: 重置选择的顺序
    private func resetSelectionOrder() {
        for asset in selectedAssets {
            if !asset.isSelected {
                let index = selectedAssets.firstIndex(of: asset)!
                selectedAssets.remove(at: index)
            }
        }
        for index in 0 ..< selectedAssets.count {
            selectedAssets[index].selectionOrder = index
        }
        
    }
    
    private func reloadData() {
        previewButton.isEnabled = selectedAssets.count > 0
        doneButton.isEnabled = selectedAssets.count > 0
        UIView.setAnimationsEnabled(false)
        let index = IndexSet(integer: IndexSet.Element(bitPattern: 0))
        UIView.animate(withDuration: 0) { [weak self] in
            self?.assetCollectionView.performBatchUpdates({
                self?.assetCollectionView.reloadSections(index)
            }, completion: { _ in
                UIView.setAnimationsEnabled(true)
            })
        }
    }
    
}
