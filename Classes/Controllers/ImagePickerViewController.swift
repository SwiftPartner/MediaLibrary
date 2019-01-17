//
//  ImagePickerViewController.swift
//  MediaLibrary
//
//  Created by Ryan on 2018/11/24.
//  Copyright © 2018 深圳市昊昱显信息技术有限公司. All rights reserved.
//

import UIKit
import Photos

open class ImagePickerViewController: UINavigationController {
    
    public typealias AssetsSelectionCallback = ((SelectionAction) -> (isAssetSelectable: Bool, unSelectableReason: String?)?)

    public var selectAssetCallback: AssetsSelectionCallback?
    weak var toolBar: UIToolbar?
    
    public var selectedAssets: [PHAsset]?
    
    public convenience init() {
        self.init(selectedAssets: nil)
    }
    
    init(selectedAssets: [PHAsset]?) {
        super.init(nibName: nil, bundle: nil)
        self.selectedAssets = selectedAssets
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public enum FirstVisibleScene {
        case albums
        case assets
        case preview(assets: [PHAsset])
    }

    
    public struct Configuration {
        public var firstVisibleScene: FirstVisibleScene = .assets
        public var maxNumberOfSelection = 9
        public static let `default` = Configuration(firstVisibleScene: .assets, maxNumberOfSelection: 9)
    }
    
    public static var configuration: Configuration = Configuration.default
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        configChildControllers()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @objc private func done() {
        
    }
    
    // MARK: 配置子控制器，因为这里可能首先进入的是相册，也可能直接选择图片
    private func configChildControllers() {
//        if PHPhotoLibrary.authorizationStatus() != .authorized {
//            fatalError("请先获取到相册权限后再调用")
//        }
        let bundle = Bundle(for: AssetsViewController.self)
        let config = ImagePickerViewController.configuration
        let albumsController = AlbumsViewController(nibName: "AlbumsViewController", bundle: bundle)
        albumsController.cancelCallback = { [weak self] in
            _ = self?.selectAssetCallback?(.cancel)
        }
        albumsController.callback = { [weak self] assetController in
            assetController.selectAssetCallback = self?.selectAssetCallback
        }
        
        switch config.firstVisibleScene {
        case .assets:
            let assetsController = AssetsViewController(nibName: "AssetsViewController", bundle: bundle)
            if let assets = selectedAssets {
                assetsController.selectedAssets = assets
            }
            assetsController.title = NSLocalizedString("All Photos", bundle: bundle ,comment: "所有照片")
            assetsController.selectAssetCallback = selectAssetCallback
            viewControllers = [albumsController, assetsController]
        case .albums:
            viewControllers = [albumsController]
        case .preview(let assets):
            let assetsController = AssetsViewController(nibName: "AssetsViewController", bundle: bundle)
            assetsController.selectedAssets = assets
            assetsController.title = NSLocalizedString("All Photos", bundle: bundle ,comment: "所有照片")
            assetsController.selectAssetCallback = selectAssetCallback
            
            let previewController = PreviewViewController(nibName: "PreviewViewController", bundle: bundle)
            previewController.selectedAssets = assets
            viewControllers = [albumsController, assetsController, previewController]
        }
    }
    
    
}
